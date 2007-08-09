From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 09 Aug 2007 18:02:08 +0000
Subject: mmap broken?
Message-Id: <ed5aea430708091102q26cc5a39uf67210652e7354c2@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_132691_4327736.1186682528115"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_132691_4327736.1186682528115
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

There is a libunwind test-case that used to work fine but fails with
recent kernels (e.g., 2.6.23-rc2).  The problem is exhibited by the
attached test program.  It attempts to map the page right after the
register-backing-store area with a no-access page.  The mmap call
succeeds, but the kernel incorrectly maps the no-access page not at
the desired location, but at the next page.  If I specify MAP_FIXED,
the mmap() call succeeds, but I don't think MAP_FIXED should be
necessary here.  Anybody can think of any patches that would explain
this change of behavior?

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_132691_4327736.1186682528115
Content-Type: text/x-csrc; name=test-mmap.c; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f55k05ad
Content-Disposition: attachment; filename="test-mmap.c"

I2luY2x1ZGUgPGlhNjRpbnRyaW4uaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxzdGRp
bnQuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHVu
aXN0ZC5oPgoKI2luY2x1ZGUgPHN5cy9tbWFuLmg+Cgp1aW50cHRyX3QKZ2V0X2JzcCAodm9pZCkK
ewojaWZkZWYgX19JTlRFTF9DT01QSUxFUgogIHJldHVybiBfX2dldFJlZyAoX0lBNjRfUkVHX0FS
X0JTUCk7CiNlbHNlCiAgcmV0dXJuICh1aW50cHRyX3QpIF9fYnVpbHRpbl9pYTY0X2JzcCAoKTsK
I2VuZGlmCn0KCmludAptYWluIChpbnQgYXJnYywgY2hhciAqKmFyZ3YpCnsKCXVpbnRwdHJfdCBn
dWFyZF9wYWdlX2FkZHIsIGJzcCA9IGdldF9ic3AgKCk7CglzaXplX3QgcGFnZV9zaXplID0gZ2V0
cGFnZXNpemUgKCk7CgljaGFyIGJ1Zls4MTkyXTsKCXNzaXplX3QgbnJlYWQ7Cgl2b2lkICpyZXQ7
CglpbnQgZmQ7CgoJZ3VhcmRfcGFnZV9hZGRyID0gKGJzcCArIHBhZ2Vfc2l6ZSAtIDEpICYgLXBh
Z2Vfc2l6ZTsKCXByaW50ZigiZ3VhcmRfcGFnZV9hZGRyID0gMHglbHhcbiIsICh1bnNpZ25lZCBs
b25nKSBndWFyZF9wYWdlX2FkZHIpOwoJcmV0ID0gbW1hcCgodm9pZCAqKSBndWFyZF9wYWdlX2Fk
ZHIsIHBhZ2Vfc2l6ZSwgUFJPVF9OT05FLAoJCSAgIE1BUF9TSEFSRUQgfCBNQVBfQU5PTllNT1VT
LCAtMSwgMCk7CglpZiAocmV0ICE9ICh2b2lkICopIGd1YXJkX3BhZ2VfYWRkcikgewoJCWZwcmlu
dGYoc3RkZXJyLCAibW1hcCgpIHJldHVybmVkICVwLCBleHBlY3RlZCAweCVseFxuIiwKCQkJcmV0
LCBndWFyZF9wYWdlX2FkZHIpOwoJCWlmIChyZXQgPT0gTUFQX0ZBSUxFRCkKCQkJcGVycm9yICgi
bW1hcCIpOwoJfQoJZmQgPSBvcGVuKCIvcHJvYy9zZWxmL21hcHMiLCBPX1JET05MWSk7CglucmVh
ZCA9IHJlYWQoZmQsIGJ1Ziwgc2l6ZW9mKGJ1ZikpOwoJd3JpdGUoMSwgYnVmLCBucmVhZCk7Cgly
ZXR1cm4gMDsKfQo=
------=_Part_132691_4327736.1186682528115--
