From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Feb 2004 22:56:15 +0000
Subject: RE: Duplicated do_softirq in the interrupt path
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB3E@scsmsx401.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3FCBB.BCC9933E"
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB501F2AB3C@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB501F2AB3C@scsmsx401.sc.intel.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3FCBB.BCC9933E
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

OK, this is what I come up with.  The irq_enter need to be moved as
well.  Otherwise, it will increment preempt_count on every interrupt.

- Ken


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]=20
Sent: Thursday, February 26, 2004 2:50 PM
To: Chen, Kenneth W
Cc: linux-ia64@vger.kernel.org
Subject: Re: Duplicated do_softirq in the interrupt path


>>>>> On Thu, 26 Feb 2004 14:20:33 -0800, "Chen, Kenneth W"
<kenneth.w.chen@intel.com> said:

  Ken> do_softirq appeared twice in the interrupt path, once in do_IRQ()
and
  Ken> once in the higher level function ia64_handle_irq().  The
condition
  Ken> check for running do_softirq in ia64_handle_irq() doesn't do
preemption
  Ken> check and obviously a leftover code.  But I'm more concerned with
  Ken> softirq being executed while lower priority interrupt is blocked
due
  Ken> to eoi and tpr only gets updated after the return of do_IRQ,
which
  Ken> already executed bottom half for the higher priority interrupt.
Isn't
  Ken> it better to execute all critical part of interrupts (including
lower
  Ken> priority) and batch processing all the bottom half handler?

Absolutely!  In fact, wouldn't that explain the keyboard problems that
were reported for Lion?

I think the correct fix is to move irq_exit() from do_IRQ() to the
point where ia64_handle_irq() calls do_softirq().  Unfortunately, this
makes for one more difference compared to arch/i386/kernel/irq.c but I
don't see any other reasonable way to resolve the problem.

	--david

------_=_NextPart_001_01C3FCBB.BCC9933E
Content-Type: application/octet-stream;
	name="irq.patch"
Content-Transfer-Encoding: base64
Content-Description: irq.patch
Content-Disposition: attachment;
	filename="irq.patch"

ZGlmZiAtTnVycCBsaW51eC0yLjYuMy9hcmNoL2lhNjQva2VybmVsL2lycS5jIGxpbnV4LTIuNi4z
LmVvaS9hcmNoL2lhNjQva2VybmVsL2lycS5jCi0tLSBsaW51eC0yLjYuMy9hcmNoL2lhNjQva2Vy
bmVsL2lycS5jCTIwMDQtMDItMTcgMTk6NTk6MjEuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0y
LjYuMy5lb2kvYXJjaC9pYTY0L2tlcm5lbC9pcnEuYwkyMDA0LTAyLTI2IDE0OjEzOjExLjAwMDAw
MDAwMCAtMDgwMApAQCAtNDU1LDcgKzQ1NSw2IEBAIHVuc2lnbmVkIGludCBkb19JUlEodW5zaWdu
ZWQgbG9uZyBpcnEsIHMKIAl1bnNpZ25lZCBpbnQgc3RhdHVzOwogCWludCBjcHU7CiAKLQlpcnFf
ZW50ZXIoKTsKIAljcHUgPSBzbXBfcHJvY2Vzc29yX2lkKCk7IC8qIGZvciBDT05GSUdfUFJFRU1Q
VCwgdGhpcyBtdXN0IGNvbWUgYWZ0ZXIgaXJxX2VudGVyKCkhICovCiAKIAlrc3RhdF9jcHUoY3B1
KS5pcnFzW2lycV0rKzsKQEAgLTUyNSw3ICs1MjQsNiBAQCB1bnNpZ25lZCBpbnQgZG9fSVJRKHVu
c2lnbmVkIGxvbmcgaXJxLCBzCiAJCWRlc2MtPmhhbmRsZXItPmVuZChpcnEpOwogCQlzcGluX3Vu
bG9jaygmZGVzYy0+bG9jayk7CiAJfQotCWlycV9leGl0KCk7CiAJcmV0dXJuIDE7CiB9CiAKZGlm
ZiAtTnVycCBsaW51eC0yLjYuMy9hcmNoL2lhNjQva2VybmVsL2lycV9pYTY0LmMgbGludXgtMi42
LjMuZW9pL2FyY2gvaWE2NC9rZXJuZWwvaXJxX2lhNjQuYwotLS0gbGludXgtMi42LjMvYXJjaC9p
YTY0L2tlcm5lbC9pcnFfaWE2NC5jCTIwMDQtMDItMTcgMTk6NTc6MzAuMDAwMDAwMDAwIC0wODAw
CisrKyBsaW51eC0yLjYuMy5lb2kvYXJjaC9pYTY0L2tlcm5lbC9pcnFfaWE2NC5jCTIwMDQtMDIt
MjYgMTQ6MTM6MTQuMDAwMDAwMDAwIC0wODAwCkBAIC0xMjAsNiArMTIwLDcgQEAgaWE2NF9oYW5k
bGVfaXJxIChpYTY0X3ZlY3RvciB2ZWN0b3IsIHN0cgogCSAqIDE2ICh3aXRob3V0IHRoaXMsIGl0
IHdvdWxkIGJlIH4yNDAsIHdoaWNoIGNvdWxkIGVhc2lseSBsZWFkCiAJICogdG8ga2VybmVsIHN0
YWNrIG92ZXJmbG93cykuCiAJICovCisJaXJxX2VudGVyKCk7CiAJc2F2ZWRfdHByID0gaWE2NF9n
ZXRyZWcoX0lBNjRfUkVHX0NSX1RQUik7CiAJaWE2NF9zcmx6X2QoKTsKIAl3aGlsZSAodmVjdG9y
ICE9IElBNjRfU1BVUklPVVNfSU5UX1ZFQ1RPUikgewpAQCAtMTQzLDggKzE0NCw3IEBAIGlhNjRf
aGFuZGxlX2lycSAoaWE2NF92ZWN0b3IgdmVjdG9yLCBzdHIKIAkgKiBoYW5kbGVyIG5lZWRzIHRv
IGJlIGFibGUgdG8gd2FpdCBmb3IgZnVydGhlciBrZXlib2FyZCBpbnRlcnJ1cHRzLCB3aGljaCBj
YW4ndAogCSAqIGNvbWUgdGhyb3VnaCB1bnRpbCBpYTY0X2VvaSgpIGhhcyBiZWVuIGRvbmUuCiAJ
ICovCi0JaWYgKGxvY2FsX3NvZnRpcnFfcGVuZGluZygpKQotCQlkb19zb2Z0aXJxKCk7CisJaXJx
X2V4aXQoKTsKIH0KIAogI2lmZGVmIENPTkZJR19TTVAK

------_=_NextPart_001_01C3FCBB.BCC9933E--
