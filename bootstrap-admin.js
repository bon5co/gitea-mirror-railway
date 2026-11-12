// Creates the first (admin) account through the app's own sign-up endpoint, then upstream closes sign-up.
// Idempotent: on a redeploy the account exists and sign-up answers 403 SIGNUP_CLOSED, which is the expected outcome.
const port = process.env.PORT || "4321";
const base = `http://127.0.0.1:${port}`;
const origin = process.env.BETTER_AUTH_URL || base;
const email = process.env.ADMIN_EMAIL;
const password = process.env.ADMIN_PASSWORD;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function healthy() {
  try {
    const r = await fetch(`${base}/api/health`);
    return r.ok;
  } catch {
    return false;
  }
}

for (let i = 0; i < 150 && !(await healthy()); i++) await sleep(2000);
if (!(await healthy())) {
  console.log("bootstrap-admin: app never became healthy, giving up");
  process.exit(0);
}

const r = await fetch(`${base}/api/auth/sign-up/email`, {
  method: "POST",
  headers: { "Content-Type": "application/json", Origin: origin },
  body: JSON.stringify({ email, password, name: email.split("@")[0] }),
});
const body = await r.text();
if (r.ok) console.log(`bootstrap-admin: admin account created for ${email}`);
else if (r.status === 403) console.log("bootstrap-admin: account already exists, sign-up closed");
else console.log(`bootstrap-admin: sign-up answered ${r.status}: ${body.slice(0, 200)}`);
