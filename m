From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 19 Sep 2005 16:43:24 +0000
Subject: RE: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F046A23C3@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C5BD39.41185688"
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C5BD39.41185688
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


>Very odd.  I don't see a warning with the current code (using gcc 3.4).
>But when I applied this patch, I did get a warning (which is what made
>me take a closer[1] look at this part).

Ok.  the definition of the pal_freq_ratio structure uses 32-bit wide
bitfields that are type u64.  So something changed in gcc between
3.4 and 4.0 about how such a declaration is interpreted.

Anyone know which is right?

We could change the definition in asm/pal.h to read:

typedef[1] struct pal_freq_ratio {
	u32	den;
	u32	num;
} itc_ratio, proc_ratio;

and then both version of gcc would be happy with "%u" (but there
are a few more spots to change in palinfo.c in addition to the
change to time.c ... doesn't gcc 4 spit out warnings for line 654
of palinfo.c args 3, 4, 5, 6, 7, 8?  If not, why not?)

Is there any reason to prefer bitfields over separate elements here?

Does the attached patch make gcc 4.0 happy?

-Tony

[1] we could kill this typedef while editing here, nobody uses
the "itc_ratio" and proc_ratio" types.  All places that use this
just use "struct pal_freq_ratio ...".

------_=_NextPart_001_01C5BD39.41185688
Content-Type: application/octet-stream;
	name="proc-freq-info.patch"
Content-Transfer-Encoding: base64
Content-Description: proc-freq-info.patch
Content-Disposition: attachment;
	filename="proc-freq-info.patch"

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvcGFsaW5mby5jIGIvYXJjaC9pYTY0L2tlcm5l
bC9wYWxpbmZvLmMKLS0tIGEvYXJjaC9pYTY0L2tlcm5lbC9wYWxpbmZvLmMKKysrIGIvYXJjaC9p
YTY0L2tlcm5lbC9wYWxpbmZvLmMKQEAgLTY0OCw5ICs2NDgsOSBAQCBmcmVxdWVuY3lfaW5mbyhj
aGFyICpwYWdlKQogCWlmIChpYTY0X3BhbF9mcmVxX3JhdGlvcygmcHJvYywgJmJ1cywgJml0Yykg
IT0gMCkgcmV0dXJuIDA7CiAKIAlwICs9IHNwcmludGYocCwKLQkJICAgICAiUHJvY2Vzc29yL0Ns
b2NrIHJhdGlvICAgOiAlbGQvJWxkXG4iCi0JCSAgICAgIkJ1cy9DbG9jayByYXRpbyAgICAgICAg
IDogJWxkLyVsZFxuIgotCQkgICAgICJJVEMvQ2xvY2sgcmF0aW8gICAgICAgICA6ICVsZC8lbGRc
biIsCisJCSAgICAgIlByb2Nlc3Nvci9DbG9jayByYXRpbyAgIDogJXUvJXVcbiIKKwkJICAgICAi
QnVzL0Nsb2NrIHJhdGlvICAgICAgICAgOiAldS8ldVxuIgorCQkgICAgICJJVEMvQ2xvY2sgcmF0
aW8gICAgICAgICA6ICV1LyV1XG4iLAogCQkgICAgIHByb2MubnVtLCBwcm9jLmRlbiwgYnVzLm51
bSwgYnVzLmRlbiwgaXRjLm51bSwgaXRjLmRlbik7CiAKIAlyZXR1cm4gcCAtIHBhZ2U7CmRpZmYg
LS1naXQgYS9hcmNoL2lhNjQva2VybmVsL3RpbWUuYyBiL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5j
Ci0tLSBhL2FyY2gvaWE2NC9rZXJuZWwvdGltZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvdGlt
ZS5jCkBAIC0xOTIsNyArMTkyLDcgQEAgaWE2NF9pbml0X2l0bSAodm9pZCkKIAlpdGNfZnJlcSA9
IChwbGF0Zm9ybV9iYXNlX2ZyZXEqaXRjX3JhdGlvLm51bSkvaXRjX3JhdGlvLmRlbjsKIAogCWxv
Y2FsX2NwdV9kYXRhLT5pdG1fZGVsdGEgPSAoaXRjX2ZyZXEgKyBIWi8yKSAvIEhaOwotCXByaW50
ayhLRVJOX0RFQlVHICJDUFUgJWQ6IGJhc2UgZnJlcT0lbHUuJTAzbHVNSHosIElUQyByYXRpbz0l
bHUvJWx1LCAiCisJcHJpbnRrKEtFUk5fREVCVUcgIkNQVSAlZDogYmFzZSBmcmVxPSVsdS4lMDNs
dU1IeiwgSVRDIHJhdGlvPSV1LyV1LCAiCiAJICAgICAgICJJVEMgZnJlcT0lbHUuJTAzbHVNSHoi
LCBzbXBfcHJvY2Vzc29yX2lkKCksCiAJICAgICAgIHBsYXRmb3JtX2Jhc2VfZnJlcSAvIDEwMDAw
MDAsIChwbGF0Zm9ybV9iYXNlX2ZyZXEgLyAxMDAwKSAlIDEwMDAsCiAJICAgICAgIGl0Y19yYXRp
by5udW0sIGl0Y19yYXRpby5kZW4sIGl0Y19mcmVxIC8gMTAwMDAwMCwgKGl0Y19mcmVxIC8gMTAw
MCkgJSAxMDAwKTsKZGlmZiAtLWdpdCBhL2luY2x1ZGUvYXNtLWlhNjQvcGFsLmggYi9pbmNsdWRl
L2FzbS1pYTY0L3BhbC5oCi0tLSBhL2luY2x1ZGUvYXNtLWlhNjQvcGFsLmgKKysrIGIvaW5jbHVk
ZS9hc20taWE2NC9wYWwuaApAQCAtMTI5LDkgKzEyOSwxMCBAQCB0eXBlZGVmIHU2NAkJCQlwYWxf
Y2FjaGVfbGluZV9zdGF0ZV90OwogI2RlZmluZSBQQUxfQ0FDSEVfTElORV9TVEFURV9FWENMVVNJ
VkUJMgkvKiBFeGNsdXNpdmUgKi8KICNkZWZpbmUgUEFMX0NBQ0hFX0xJTkVfU1RBVEVfTU9ESUZJ
RUQJMwkvKiBNb2RpZmllZCAqLwogCi10eXBlZGVmIHN0cnVjdCBwYWxfZnJlcV9yYXRpbyB7Ci0J
dTY0IGRlbiA6IDMyLCBudW0gOiAzMjsJLyogbnVtZXJhdG9yICYgZGVub21pbmF0b3IgKi8KLX0g
aXRjX3JhdGlvLCBwcm9jX3JhdGlvOworc3RydWN0IHBhbF9mcmVxX3JhdGlvIHsKKwl1MzIJZGVu
OwkJLyogZGVub21pbmF0b3IgKi8KKwl1MzIJbnVtOwkJLyogbnVtZXJhdG9yICovCit9OwogCiB0
eXBlZGVmCXVuaW9uICBwYWxfY2FjaGVfY29uZmlnX2luZm9fMV9zIHsKIAlzdHJ1Y3Qgewo=

------_=_NextPart_001_01C5BD39.41185688--
