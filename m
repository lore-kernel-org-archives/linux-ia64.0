From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 23 Feb 2004 16:26:32 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB09@scsmsx401.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C3FA29.CC1F314D"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C3FA29.CC1F314D
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

sorry, missed this important hunk:
 # else
 #  error Unsupported IA-64 HugeTLB Page Size!
 # endif
+#define HPAGE_SHIFT hpage_shift

Here is a work-in-progress patch that includes more comments we have.

(1) hugepagesz parameter should have min/max checked.  Doesn't make
sense to config huge page size smaller than PAGE_SIZE, or config huge
page size larger than what page allocator allows (MAX_ORDER).

(2) We can avoid patching vhpt handler and still allow dynamic sizing.

(3) we remain unhappy with penalty hit on reload_context().  Region
register 4 now has a dependency on loading variable hpage_shift, which
could have worst case two/three hundred cycles.  This variable is next
to ia64_ctx (which is heavily used), but there is no guarantee that
they sits in the same cache line.  I've tried prefetch() with
gcc-3.2.3, but it generates code that everyone can laugh at it.

(4) If we have gone this far, it probably won't take that much more
to make it runtime configurable!


- Ken


-----Original Message-----
From: Jack Steiner [mailto:steiner@sgi.com]
Sent: Sunday, February 22, 2004 3:08 PM
To: Chen, Kenneth W
Cc: linux-ia64@vger.kernel.org
Subject: Re: HUGEPAGE SIZE a boottime option


On Thu, Feb 19, 2004 at 08:00:04PM -0800, Chen, Kenneth W wrote:
> It is not functionally complete though.  alloc_fresh_huge_page(),
> hugetlb_free_pgtables(), and update_and_free_page has #define
> constant that indirectly from HPAGE_SHIFT.
>=20
> You might checked already, text replication works in this case?
>=20

(I posted this earlier. However, our mail server has been messed up & I =
dont think
the mail got thru. Excuse the duplicate if the other mail ever makes =
it....)


The patch passes preliminary testing.

I dont see any issues with #define constants indirectly using =
HPAGE_SHIFT. HPAGE_SHIFT
is now defined as:
        #define HPAGE_SHIFT hpage_shift
and
        extern int hpage_shift;        =20
        int hpage_shift=3DHPAGE_SHIFT_DEFAULT;


Indirect references should work ok.


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Jack Steiner
> Sent: Thursday, February 19, 2004 5:08 PM
> To: linux-ia64@vger.kernel.org
> Subject: HUGEPAGE SIZE a boottime option
>=20
>=20
> Here is a preliminary version of a patch that makes the size of
> HUGEPAGES a boottime option. Only ia64-specific files are changed =
(except
> for the Documentation file).
>=20
> We have a number of customers using large pages. Unfortunately,=20
> the "optimum" size of a large page is application & configuration
> dependent. Rather that having each customer recompile to specify their
> own HUGEPAGESIZE, this patch make the size a boottime option.
>=20
>=20
> Does this patch look reasonable? If so, I will incorporate feedback,
> finish testing it, update it to 2.6.3 & resubmit.

------_=_NextPart_001_01C3FA29.CC1F314D
Content-Type: application/octet-stream;
	name="htlb_size.patch"
Content-Transfer-Encoding: base64
Content-Description: htlb_size.patch
Content-Disposition: attachment;
	filename="htlb_size.patch"

ZGlmZiAtTnVyIGxpbnV4LTIuNi4zL2FyY2gvaWE2NC9rZXJuZWwvaXZ0LlMgbGludXgtMi42LjMu
aHRsYi9hcmNoL2lhNjQva2VybmVsL2l2dC5TCi0tLSBsaW51eC0yLjYuMy9hcmNoL2lhNjQva2Vy
bmVsL2l2dC5TCTIwMDQtMDItMTcgMTk6NTc6MTYuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0y
LjYuMy5odGxiL2FyY2gvaWE2NC9rZXJuZWwvaXZ0LlMJMjAwNC0wMi0yMiAyMzoxMzozNC4wMDAw
MDAwMDAgLTA4MDAKQEAgLTExOCwxMCArMTE4LDExIEBACiAjaWZkZWYgQ09ORklHX0hVR0VUTEJf
UEFHRQogCWV4dHIudSByMjY9cjI1LDIsNgogCTs7Ci0JY21wLmVxIHA4LHAwPUhQQUdFX1NISUZU
LHIyNgorCWNtcC5uZSBwOCxwMD1yMTgscjI2CisJc3ViIHIyNz1yMjYscjE4CiAJOzsKIChwOCkJ
ZGVwIHIyNT1yMTgscjI1LDIsNgotKHA4KQlzaHIgcjIyPXIyMixIUEFHRV9TSElGVC1QQUdFX1NI
SUZUCisocDgpCXNociByMjI9cjIyLHIyNwogI2VuZGlmCiAJOzsKIAljbXAuZXEgcDYscDc9NSxy
MTcJCQkvLyBpcyBJRkEgcG9pbnRpbmcgaW50byB0byByZWdpb24gNT8KZGlmZiAtTnVyIGxpbnV4
LTIuNi4zL2FyY2gvaWE2NC9tbS9odWdldGxicGFnZS5jIGxpbnV4LTIuNi4zLmh0bGIvYXJjaC9p
YTY0L21tL2h1Z2V0bGJwYWdlLmMKLS0tIGxpbnV4LTIuNi4zL2FyY2gvaWE2NC9tbS9odWdldGxi
cGFnZS5jCTIwMDQtMDItMTcgMTk6NTg6MDEuMDAwMDAwMDAwIC0wODAwCisrKyBsaW51eC0yLjYu
My5odGxiL2FyY2gvaWE2NC9tbS9odWdldGxicGFnZS5jCTIwMDQtMDItMjIgMjI6NTg6NTguMDAw
MDAwMDAwIC0wODAwCkBAIC0yMyw2ICsyMyw3IEBACiBzdGF0aWMgbG9uZwlodGxicGFnZW1lbTsK
IGludAkJaHRsYnBhZ2VfbWF4Owogc3RhdGljIGxvbmcJaHRsYnpvbmVfcGFnZXM7Cit1bnNpZ25l
ZCBpbnQJaHBhZ2Vfc2hpZnQ9SFBBR0VfU0hJRlRfREVGQVVMVDsKIAogc3RhdGljIHN0cnVjdCBs
aXN0X2hlYWQgaHVnZXBhZ2VfZnJlZWxpc3RzW01BWF9OVU1OT0RFU107CiBzdGF0aWMgc3Bpbmxv
Y2tfdCBodGxicGFnZV9sb2NrID0gU1BJTl9MT0NLX1VOTE9DS0VEOwpAQCAtNTIwLDYgKzUyMSwz
MCBAQAogfQogX19zZXR1cCgiaHVnZXBhZ2VzPSIsIGh1Z2V0bGJfc2V0dXApOwogCitzdGF0aWMg
aW50IF9faW5pdCBodWdldGxiX3NldHVwX3N6KGNoYXIgKnN0cikKK3sKKwl1NjQgdHJfcGFnZXM7
CisJdW5zaWduZWQgbG9uZyBsb25nIHNpemU7CisKKwlpZiAoaWE2NF9wYWxfdm1fcGFnZV9zaXpl
KCZ0cl9wYWdlcywgTlVMTCkgIT0gMCkKKwkJLyoKKwkJICogc2hvdWxkbid0IGhhcHBlbiwgYnV0
IGp1c3QgaW4gY2FzZS4KKwkJICovCisJCXRyX3BhZ2VzID0gMHgxNTU1NzAwMFVMOworCisJc2l6
ZSA9IG1lbXBhcnNlKHN0ciwgJnN0cik7CisJaWYgKCpzdHIgfHwgKHNpemUgJiAoc2l6ZS0xKSkg
fHwgISh0cl9wYWdlcyAmIHNpemUpIHx8CisJCXNpemUgPD0gUEFHRV9TSVpFIHx8CisJCXNpemUg
Pj0gKDFVTCA8PCBQQUdFX1NISUZUIDw8IE1BWF9PUkRFUikpIHsKKwkJcHJpbnRrKEtFUk5fV0FS
TklORyAiSW52YWxpZCBodWdlIHBhZ2Ugc2l6ZSBzcGVjaWZpZWRcbiIpOworCQlyZXR1cm4gMTsK
Kwl9CisKKwlocGFnZV9zaGlmdCA9IF9fZmZzKHNpemUpOworCXJldHVybiAxOworfQorX19zZXR1
cCgiaHVnZXBhZ2Vzej0iLCBodWdldGxiX3NldHVwX3N6KTsKKwogc3RhdGljIGludCBfX2luaXQg
aHVnZXRsYl9pbml0KHZvaWQpCiB7CiAJaW50IGk7CmRpZmYgLU51ciBsaW51eC0yLjYuMy9pbmNs
dWRlL2FzbS1pYTY0L3BhZ2UuaCBsaW51eC0yLjYuMy5odGxiL2luY2x1ZGUvYXNtLWlhNjQvcGFn
ZS5oCi0tLSBsaW51eC0yLjYuMy9pbmNsdWRlL2FzbS1pYTY0L3BhZ2UuaAkyMDA0LTAyLTE3IDE5
OjU3OjE2LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjMuaHRsYi9pbmNsdWRlL2FzbS1p
YTY0L3BhZ2UuaAkyMDA0LTAyLTIyIDE3OjI2OjE4LjAwMDAwMDAwMCAtMDgwMApAQCAtMzcsMjYg
KzM3LDI2IEBACiAjZGVmaW5lIFJHTl9NQVBfTElNSVQJKCgxVUwgPDwgKDQqUEFHRV9TSElGVCAt
IDEyKSkgLSBQQUdFX1NJWkUpCS8qIHBlciByZWdpb24gYWRkciBsaW1pdCAqLwogCiAjaWZkZWYg
Q09ORklHX0hVR0VUTEJfUEFHRQotCiAjIGlmIGRlZmluZWQoQ09ORklHX0hVR0VUTEJfUEFHRV9T
SVpFXzRHQikKLSMgIGRlZmluZSBIUEFHRV9TSElGVAkzMgorIyAgZGVmaW5lIEhQQUdFX1NISUZU
X0RFRkFVTFQJMzIKICMgZWxpZiBkZWZpbmVkKENPTkZJR19IVUdFVExCX1BBR0VfU0laRV8xR0Ip
Ci0jICBkZWZpbmUgSFBBR0VfU0hJRlQJMzAKKyMgIGRlZmluZSBIUEFHRV9TSElGVF9ERUZBVUxU
CTMwCiAjIGVsaWYgZGVmaW5lZChDT05GSUdfSFVHRVRMQl9QQUdFX1NJWkVfMjU2TUIpCi0jICBk
ZWZpbmUgSFBBR0VfU0hJRlQJMjgKKyMgIGRlZmluZSBIUEFHRV9TSElGVF9ERUZBVUxUCTI4CiAj
IGVsaWYgZGVmaW5lZChDT05GSUdfSFVHRVRMQl9QQUdFX1NJWkVfNjRNQikKLSMgIGRlZmluZSBI
UEFHRV9TSElGVAkyNgorIyAgZGVmaW5lIEhQQUdFX1NISUZUX0RFRkFVTFQJMjYKICMgZWxpZiBk
ZWZpbmVkKENPTkZJR19IVUdFVExCX1BBR0VfU0laRV8xNk1CKQotIyAgZGVmaW5lIEhQQUdFX1NI
SUZUCTI0CisjICBkZWZpbmUgSFBBR0VfU0hJRlRfREVGQVVMVAkyNAogIyBlbGlmIGRlZmluZWQo
Q09ORklHX0hVR0VUTEJfUEFHRV9TSVpFXzRNQikKLSMgIGRlZmluZSBIUEFHRV9TSElGVAkyMgor
IyAgZGVmaW5lIEhQQUdFX1NISUZUX0RFRkFVTFQJMjIKICMgZWxpZiBkZWZpbmVkKENPTkZJR19I
VUdFVExCX1BBR0VfU0laRV8xTUIpCi0jICBkZWZpbmUgSFBBR0VfU0hJRlQJMjAKKyMgIGRlZmlu
ZSBIUEFHRV9TSElGVF9ERUZBVUxUCTIwCiAjIGVsaWYgZGVmaW5lZChDT05GSUdfSFVHRVRMQl9Q
QUdFX1NJWkVfMjU2S0IpCi0jICBkZWZpbmUgSFBBR0VfU0hJRlQJMTgKKyMgIGRlZmluZSBIUEFH
RV9TSElGVF9ERUZBVUxUCTE4CiAjIGVsc2UKICMgIGVycm9yIFVuc3VwcG9ydGVkIElBLTY0IEh1
Z2VUTEIgUGFnZSBTaXplIQogIyBlbmRpZgorI2RlZmluZSBIUEFHRV9TSElGVCBocGFnZV9zaGlm
dAogCiAjIGRlZmluZSBSRUdJT05fSFBBR0UJKDRVTCkJLyogbm90ZTogdGhpcyBpcyBoYXJkY29k
ZWQgaW4gbW11X2NvbnRleHQuaDpyZWxvYWRfY29udGV4dCgpISovCiAjIGRlZmluZSBSRUdJT05f
U0hJRlQJNjEKQEAgLTE0MCw2ICsxNDAsNyBAQAogIyBkZWZpbmUgaXNfaHVnZXBhZ2Vfb25seV9y
YW5nZShhZGRyLCBsZW4pCQlcCiAJIChSRUdJT05fTlVNQkVSKGFkZHIpID09IFJFR0lPTl9IUEFH
RSAmJglcCiAJICBSRUdJT05fTlVNQkVSKChhZGRyKSsobGVuKSkgPT0gUkVHSU9OX0hQQUdFKQor
ZXh0ZXJuIHVuc2lnbmVkIGludCBocGFnZV9zaGlmdDsKICNlbmRpZgogCiBzdGF0aWMgX19pbmxp
bmVfXyBpbnQK

------_=_NextPart_001_01C3FA29.CC1F314D--
