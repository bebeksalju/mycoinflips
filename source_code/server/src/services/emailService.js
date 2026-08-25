const RESEND_ENDPOINT = 'https://api.resend.com/emails';

const escapeHtml = (value = '') => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#039;');

const sendEmail = async ({ to, subject, html, text, from }) => {
  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) throw new Error('RESEND_API_KEY is not configured');

  const sender = from || process.env.EMAIL_FROM || 'no-reply@mcfoption.com';
  const response = await fetch(RESEND_ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: `MCFOPTION <${sender}>`,
      to: [to],
      subject,
      html,
      text
    })
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = data?.message || data?.error || `Resend request failed with ${response.status}`;
    throw new Error(message);
  }

  return data;
};

const sendPasswordResetEmail = async ({ to, name, resetUrl }) => {
  const safeName = escapeHtml(name || 'Trader');
  const safeUrl = escapeHtml(resetUrl);
  const subject = 'Reset your MCFOPTION password';

  const html = `
    <div style="margin:0;padding:32px;background:#07080b;font-family:Arial,sans-serif;color:#f5f5f2">
      <div style="max-width:560px;margin:0 auto;background:#111318;border:1px solid #2d2a20;border-radius:18px;padding:32px">
        <div style="font-size:24px;font-weight:800;letter-spacing:1px;margin-bottom:24px"><span style="color:#e5b84b">MCF</span><span style="color:#e5e5e5">OPTION</span></div>
        <h1 style="font-size:24px;margin:0 0 16px">Reset your password</h1>
        <p style="color:#a3a6ad;line-height:1.65">Hi ${safeName}, we received a request to reset the password for your MCFOPTION account.</p>
        <a href="${safeUrl}" style="display:inline-block;margin:18px 0;padding:13px 20px;border-radius:10px;background:#d5a438;color:#111;text-decoration:none;font-weight:800">Reset Password</a>
        <p style="color:#777b84;font-size:13px;line-height:1.6">This link expires in 15 minutes. If you did not request a password reset, you can ignore this email.</p>
        <p style="color:#555961;font-size:12px;word-break:break-all">${safeUrl}</p>
      </div>
    </div>`;

  const text = `Reset your MCFOPTION password\n\nOpen this link within 15 minutes:\n${resetUrl}\n\nIf you did not request this, ignore this email.`;
  return sendEmail({ to, subject, html, text });
};

module.exports = { sendEmail, sendPasswordResetEmail };
