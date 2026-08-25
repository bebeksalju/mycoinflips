const prisma = require('../db');
const { sendEmail } = require('../services/emailService');

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const escapeHtml = (value = '') => String(value)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#039;');

const getAllowedSenders = () => [
  process.env.EMAIL_ADMIN || 'admin@mcfoption.com',
  process.env.EMAIL_SUPPORT || 'support@mcfoption.com',
  process.env.EMAIL_FROM || 'no-reply@mcfoption.com'
].map((email) => email.trim().toLowerCase());

const sendAdminEmail = async (req, res) => {
  try {
    const to = String(req.body?.to || '').trim().toLowerCase();
    const subject = String(req.body?.subject || '').trim();
    const message = String(req.body?.message || '').trim();
    const from = String(req.body?.from || process.env.EMAIL_SUPPORT || 'support@mcfoption.com')
      .trim()
      .toLowerCase();

    if (!EMAIL_RE.test(to) || to.length > 254) {
      return res.status(400).json({ error: 'Please provide a valid recipient email address.' });
    }
    if (!subject || subject.length > 180) {
      return res.status(400).json({ error: 'Subject is required and must be 180 characters or fewer.' });
    }
    if (!message || message.length > 20000) {
      return res.status(400).json({ error: 'Message is required and must be 20,000 characters or fewer.' });
    }

    const allowedSenders = getAllowedSenders();
    if (!allowedSenders.includes(from)) {
      return res.status(400).json({ error: 'Invalid sender address.' });
    }

    const safeSubject = escapeHtml(subject);
    const safeMessage = escapeHtml(message).replace(/\n/g, '<br>');
    const html = `
      <div style="margin:0;padding:32px 18px;background:#07080b;font-family:Arial,sans-serif;color:#f5f5f2">
        <div style="max-width:620px;margin:0 auto;background:#111318;border:1px solid #2d2a20;border-radius:18px;overflow:hidden">
          <div style="padding:26px 30px;border-bottom:1px solid #24262b">
            <div style="font-size:24px;font-weight:800;letter-spacing:1px"><span style="color:#e5b84b">MCF</span><span style="color:#e5e5e5">OPTION</span></div>
          </div>
          <div style="padding:30px">
            <h1 style="font-size:22px;line-height:1.35;margin:0 0 20px;color:#f5f5f2">${safeSubject}</h1>
            <div style="color:#b3b5bb;font-size:15px;line-height:1.75">${safeMessage}</div>
          </div>
          <div style="padding:18px 30px;border-top:1px solid #24262b;color:#666a72;font-size:12px;line-height:1.5">
            MCFOPTION • Trade • Flip • Grow
          </div>
        </div>
      </div>`;

    const result = await sendEmail({
      to,
      subject,
      html,
      text: message,
      from
    });

    try {
      const forwarded = req.headers['x-forwarded-for'];
      const ipAddress = Array.isArray(forwarded)
        ? forwarded[0]
        : String(forwarded || req.socket.remoteAddress || '').split(',')[0].trim();

      await prisma.auditLog.create({
        data: {
          userId: req.user.userId,
          userEmail: req.user.email,
          userName: req.user.name || 'Admin',
          action: `Sent email from ${from} to ${to} with subject "${subject}"`,
          ipAddress
        }
      });
    } catch (auditError) {
      console.error('Email audit log error:', auditError.message);
    }

    return res.json({
      success: true,
      message: 'Email sent successfully.',
      id: result?.id || null,
      from,
      to
    });
  } catch (error) {
    console.error('Admin email send error:', error.message);
    return res.status(502).json({ error: 'Unable to send email. Please verify the Resend configuration and try again.' });
  }
};

module.exports = { sendAdminEmail };
