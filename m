From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Jun 2004 22:25:23 +0000
Subject: RE: [PATCH] module relocation code
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F018CB8FB@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C45E27.F8C62010"
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C45E27.F8C62010
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I'm hitting this problem because the module I want to load
was compiled with "-g", so the filesize is absolutely huge.
kernel/module.c does a vmalloc() to inhale the entire file,
and then two calls to module_alloc() (which calls vmalloc()
on ia64) to load the 'init' and 'core' sections. The 'init'
is small and slips into a gap early in the vmalloc playspace,
while the 'core' area is allocated after the huge area that
was allocated for the inhaled copy of the whole file.

I made a one coding change to Jean-Marc's version, adding
a check to see whether the init/core sections are close
enough together for the PCREL21B to reach (they almost
always are).

I've kept the test that there are no jumps from core to
init (though the message that is printed is almost as unhelpful
as the one that you get when you statically link a module
into the kernel that has calls to the discarded .exit
section :-)

This patch stalled out before on the question of whether
a PLT was overkill for a section-to-section branch, and
whether it would be better to use relaxation techniques
to extend the range.  Doing that might be more elegant in
some way, but it needs a whole heap of extra code (to count
how many relaxed branches need to be added and allocated them
as needed).  This seems a lot of extra code that is only
ever going to be exercised by maniacs like me with 49MB .ko
files.

I fixed up the comments to be a little more heplful.

Signed-off-by: <tony.luck@intel.com>

------_=_NextPart_001_01C45E27.F8C62010
Content-Type: application/octet-stream;
	name="module.patch"
Content-Transfer-Encoding: base64
Content-Description: module.patch
Content-Disposition: attachment;
	filename="module.patch"

ZGlmZiAtcnUgbGludXgtMi42LjcvYXJjaC9pYTY0L2tlcm5lbC9tb2R1bGUuYyB0b255LTIuNi43
L2FyY2gvaWE2NC9rZXJuZWwvbW9kdWxlLmMNCi0tLSBsaW51eC0yLjYuNy9hcmNoL2lhNjQva2Vy
bmVsL21vZHVsZS5jCTIwMDQtMDYtMTUgMjI6MTk6MjIuMDAwMDAwMDAwIC0wNzAwDQorKysgdG9u
eS0yLjYuNy9hcmNoL2lhNjQva2VybmVsL21vZHVsZS5jCTIwMDQtMDYtMjkgMTQ6NTA6NDAuMDAw
MDAwMDAwIC0wNzAwDQpAQCAtNjU2LDggKzY1NiwyNiBAQA0KIAkgICAgICBjYXNlIFJWX1BDUkVM
Og0KIAkJc3dpdGNoIChyX3R5cGUpIHsNCiAJCSAgICAgIGNhc2UgUl9JQTY0X1BDUkVMMjFCOg0K
LQkJCS8qIHNwZWNpYWwgYmVjYXVzZSBpdCBjYW4gY3Jvc3MgaW50byBvdGhlciBtb2R1bGUva2Vy
bmVsLWNvcmUuICAqLw0KLQkJCWlmICghaXNfaW50ZXJuYWwobW9kLCB2YWwpKQ0KKwkJCWlmIChp
bl9pbml0KG1vZCwgdmFsKSkgew0KKwkJCQkvKiBDYWxscyB0byBpbml0IGNvZGUgZnJvbSBjb3Jl
IGFyZSBiYWQgbmV3cyAqLw0KKwkJCQlpZiAoaW5fY29yZShtb2QsICh1aW50NjRfdClsb2NhdGlv
bikpIHsNCisJCQkJCXByaW50ayhLRVJOX0VSUiAiJXM6IGluaXQgc3ltYm9sIDB4JWx4IHVzZWQg
aW4gbW9kdWxlIGNvZGUgYXQgJXBcbiIsDQorCQkJCQkJbW9kLT5uYW1lLCB2YWwsIGxvY2F0aW9u
KTsNCisJCQkJCXJldHVybiAtRU5PRVhFQzsNCisJCQkJfQ0KKwkJCX0gZWxzZSBpZiAoaW5fY29y
ZShtb2QsIHZhbCkpIHsNCisJCQkJLyoNCisJCQkJICogSW5pdCBzZWN0aW9uIG1heSBoYXZlIGJl
ZW4gYWxsb2NhdGVkIGZhciBhd2F5IGZyb20gY29yZSwNCisJCQkJICogaWYgdGhlIGJyYW5jaCB3
b24ndCByZWFjaCwgdGhlbiBhbGxvY2F0ZSBhIHBsdCBmb3IgaXQuDQorCQkJCSAqLw0KKwkJCQlp
ZiAoaW5faW5pdChtb2QsICh1aW50NjRfdClsb2NhdGlvbikpIHsNCisJCQkJCXVpbnQ2NF90IGRl
bHRhID0gKChpbnQ2NF90KXZhbCAtIChpbnQ2NF90KWxvY2F0aW9uKSAvIDE2Ow0KKwkJCQkJaWYg
KGRlbHRhICsgKDEgPDwgMjApID49ICgxIDw8IDIxKSkgew0KKwkJCQkJCXZhbCA9IGdldF9mZGVz
Yyhtb2QsIHZhbCwgJm9rKTsNCisJCQkJCQl2YWwgPSBnZXRfcGx0KG1vZCwgbG9jYXRpb24sIHZh
bCwgJm9rKTsNCisJCQkJCX0NCisJCQkJfQ0KKwkJCX0gZWxzZQ0KIAkJCQl2YWwgPSBnZXRfcGx0
KG1vZCwgbG9jYXRpb24sIHZhbCwgJm9rKTsNCiAJCQkvKiBGQUxMIFRIUk9VR0ggKi8NCiAJCSAg
ICAgIGRlZmF1bHQ6DQo=

------_=_NextPart_001_01C45E27.F8C62010--
