From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 01 Mar 2001 18:19:35 +0000
Subject: [Linux-ia64] [PATCH?] Compile fixes for UP ia64 - IRQ stuff (RESEND)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1463800575-1623049879-983446797=:922"
Message-Id: <marc-linux-ia64-105590693005234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463800575-1623049879-983446797=:922
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1
Content-ID: <Pine.LNX.4.21.0103011918392.922@toy.mandrakesoft.com>
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mandrakesoft.mandrakesoft.com id MAA09811

[same as previous mail... Sent 6 hrs ago but did not arrive]

OK, I've found what was wrong... Attached patch is over 2.4.2 plus 010228
patch, and it fixes the following:

- include/asm-ia64/hardirq.h: invalid local_irq_count() usage in
  local_enter_irq()
- arch/ia64/kernel/irq_ia64.c: IPI was registered on UP also, but I don't=
 think
  it's used at all (or is it?), and what's more ipi_irqaction definition =
is
  surrounded by #ifdef CONFIG_SMP .. #endif. So I also #ifdef'ed the IPI
  registering out.

WDYT?

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and mor=
e
idiot-proof software, and universe, which produces more and more remarkab=
le
idiots. Until now, universe leads the race"  -- R. Cook

---1463800575-1623049879-983446797=:922
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="ia64-irq-compile-fix.patch"
Content-ID: <Pine.LNX.4.21.0103011239570.922@toy.mandrakesoft.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="ia64-irq-compile-fix.patch"
Content-Transfer-Encoding: BASE64

ZGlmZiAtdXJOIGxpbnV4LW9sZC9hcmNoL2lhNjQva2VybmVsL2lycV9pYTY0
LmMgbGludXgvYXJjaC9pYTY0L2tlcm5lbC9pcnFfaWE2NC5jDQotLS0gbGlu
dXgtb2xkL2FyY2gvaWE2NC9rZXJuZWwvaXJxX2lhNjQuYwlUaHUgTWFyICAx
IDA2OjU0OjE3IDIwMDENCisrKyBsaW51eC9hcmNoL2lhNjQva2VybmVsL2ly
cV9pYTY0LmMJVGh1IE1hciAgMSAwNzoxMDowNiAyMDAxDQpAQCAtMTU1LDcg
KzE1NSw5IEBADQogaW5pdF9JUlEgKHZvaWQpDQogew0KIAlyZWdpc3Rlcl9w
ZXJjcHVfaXJxKElBNjRfU1BVUklPVVNfSU5UX1ZFQ1RPUiwgTlVMTCk7DQor
I2lmZGVmIENPTkZJR19TTVANCiAJcmVnaXN0ZXJfcGVyY3B1X2lycShJQTY0
X0lQSV9WRUNUT1IsICZpcGlfaXJxYWN0aW9uKTsNCisjZW5kaWYNCiAJcGxh
dGZvcm1faXJxX2luaXQoKTsNCiB9DQogDQpCaW5hcnkgZmlsZXMgbGludXgt
b2xkL2FyY2gvaWE2NC90b29scy9wcmludF9vZmZzZXRzIGFuZCBsaW51eC9h
cmNoL2lhNjQvdG9vbHMvcHJpbnRfb2Zmc2V0cyBkaWZmZXINCmRpZmYgLXVy
TiBsaW51eC1vbGQvaW5jbHVkZS9hc20taWE2NC9oYXJkaXJxLmggbGludXgv
aW5jbHVkZS9hc20taWE2NC9oYXJkaXJxLmgNCi0tLSBsaW51eC1vbGQvaW5j
bHVkZS9hc20taWE2NC9oYXJkaXJxLmgJVGh1IE1hciAgMSAwNjo1NDoxOSAy
MDAxDQorKysgbGludXgvaW5jbHVkZS9hc20taWE2NC9oYXJkaXJxLmgJVGh1
IE1hciAgMSAwNzowNjo0MiAyMDAxDQpAQCAtNDEsOCArNDEsOCBAQA0KICMg
ZGVmaW5lIGxvY2FsX2hhcmRpcnFfdHJ5bG9jaygpCShsb2NhbF9pcnFfY291
bnQoKSA9PSAwKQ0KICMgZGVmaW5lIGxvY2FsX2hhcmRpcnFfZW5kbG9jaygp
CWRvIHsgfSB3aGlsZSAoMCkNCiANCi0jIGRlZmluZSBsb2NhbF9pcnFfZW50
ZXIoaXJxKQkJKGxvY2FsX2lycV9jb3VudChjcHUpKyspDQotIyBkZWZpbmUg
bG9jYWxfaXJxX2V4aXQoaXJxKQkJKGxvY2FsX2lycV9jb3VudChjcHUpLS0p
DQorIyBkZWZpbmUgbG9jYWxfaXJxX2VudGVyKGlycSkJCShsb2NhbF9pcnFf
Y291bnQoKSsrKQ0KKyMgZGVmaW5lIGxvY2FsX2lycV9leGl0KGlycSkJCShs
b2NhbF9pcnFfY291bnQoKS0tKQ0KIA0KICMgZGVmaW5lIHN5bmNocm9uaXpl
X2lycSgpCQliYXJyaWVyKCkNCiAjZWxzZQ0K
---1463800575-1623049879-983446797=:922--

