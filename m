From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Jul 2004 18:46:18 +0000
Subject: RE: strict rejection of init -> core references causes problems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F019FB649@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C465E5.05A08D57"
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C465E5.05A08D57
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Here's what the patch looks like if you do want to
drop the kernel prohibition on calls from module core
to module init routines.

Has anyone got a script that could look for other instances
of modules that do this?  If netfilter is the only one, then
it would be nice to keep the prohibition and fix netfilter
(debugging problems with bad calls after the module init
section has been freed sounds like no fun at all ... especially
if the freed page is later re-allocated to some other module).


Signed-off-by: <tony.luck@intel.com>

------_=_NextPart_001_01C465E5.05A08D57
Content-Type: application/octet-stream;
	name="module2.patch"
Content-Transfer-Encoding: base64
Content-Description: module2.patch
Content-Disposition: attachment;
	filename="module2.patch"

ZGlmZiAtcnUgb2xkL2FyY2gvaWE2NC9rZXJuZWwvbW9kdWxlLmMgbmV3L2FyY2gvaWE2NC9rZXJu
ZWwvbW9kdWxlLmMNCi0tLSBvbGQvYXJjaC9pYTY0L2tlcm5lbC9tb2R1bGUuYwkyMDA0LTA3LTA5
IDEwOjM3OjEyLjQ0NDEzMDA0MCAtMDcwMA0KKysrIG5ldy9hcmNoL2lhNjQva2VybmVsL21vZHVs
ZS5jCTIwMDQtMDctMDkgMTA6MzU6NTguNzQ0ODYxNjcyIC0wNzAwDQpAQCAtNjU2LDI2ICs2NTYs
MTggQEANCiAJICAgICAgY2FzZSBSVl9QQ1JFTDoNCiAJCXN3aXRjaCAocl90eXBlKSB7DQogCQkg
ICAgICBjYXNlIFJfSUE2NF9QQ1JFTDIxQjoNCi0JCQlpZiAoaW5faW5pdChtb2QsIHZhbCkpIHsN
Ci0JCQkJLyogQ2FsbHMgdG8gaW5pdCBjb2RlIGZyb20gY29yZSBhcmUgYmFkIG5ld3MgKi8NCi0J
CQkJaWYgKGluX2NvcmUobW9kLCAodWludDY0X3QpbG9jYXRpb24pKSB7DQotCQkJCQlwcmludGso
S0VSTl9FUlIgIiVzOiBpbml0IHN5bWJvbCAweCVseCB1c2VkIGluIG1vZHVsZSBjb2RlIGF0ICVw
XG4iLA0KLQkJCQkJCW1vZC0+bmFtZSwgdmFsLCBsb2NhdGlvbik7DQotCQkJCQlyZXR1cm4gLUVO
T0VYRUM7DQotCQkJCX0NCi0JCQl9IGVsc2UgaWYgKGluX2NvcmUobW9kLCB2YWwpKSB7DQorCQkJ
aWYgKChpbl9pbml0KG1vZCwgdmFsKSAmJiBpbl9jb3JlKG1vZCwgKHVpbnQ2NF90KWxvY2F0aW9u
KSkgfHwNCisJCQkgICAgKGluX2NvcmUobW9kLCB2YWwpICYmIGluX2luaXQobW9kLCAodWludDY0
X3QpbG9jYXRpb24pKSkgew0KIAkJCQkvKg0KIAkJCQkgKiBJbml0IHNlY3Rpb24gbWF5IGhhdmUg
YmVlbiBhbGxvY2F0ZWQgZmFyIGF3YXkgZnJvbSBjb3JlLA0KIAkJCQkgKiBpZiB0aGUgYnJhbmNo
IHdvbid0IHJlYWNoLCB0aGVuIGFsbG9jYXRlIGEgcGx0IGZvciBpdC4NCiAJCQkJICovDQotCQkJ
CWlmIChpbl9pbml0KG1vZCwgKHVpbnQ2NF90KWxvY2F0aW9uKSkgew0KLQkJCQkJdWludDY0X3Qg
ZGVsdGEgPSAoKGludDY0X3QpdmFsIC0gKGludDY0X3QpbG9jYXRpb24pIC8gMTY7DQotCQkJCQlp
ZiAoZGVsdGEgKyAoMSA8PCAyMCkgPj0gKDEgPDwgMjEpKSB7DQotCQkJCQkJdmFsID0gZ2V0X2Zk
ZXNjKG1vZCwgdmFsLCAmb2spOw0KLQkJCQkJCXZhbCA9IGdldF9wbHQobW9kLCBsb2NhdGlvbiwg
dmFsLCAmb2spOw0KLQkJCQkJfQ0KKwkJCQl1aW50NjRfdCBkZWx0YSA9ICgoaW50NjRfdCl2YWwg
LSAoaW50NjRfdClsb2NhdGlvbikgLyAxNjsNCisJCQkJaWYgKGRlbHRhICsgKDEgPDwgMjApID49
ICgxIDw8IDIxKSkgew0KKwkJCQkJdmFsID0gZ2V0X2ZkZXNjKG1vZCwgdmFsLCAmb2spOw0KKwkJ
CQkJdmFsID0gZ2V0X3BsdChtb2QsIGxvY2F0aW9uLCB2YWwsICZvayk7DQogCQkJCX0NCi0JCQl9
IGVsc2UNCisJCQl9IGVsc2UgaWYgKCFpc19pbnRlcm5hbChtb2QsIHZhbCkpDQogCQkJCXZhbCA9
IGdldF9wbHQobW9kLCBsb2NhdGlvbiwgdmFsLCAmb2spOw0KIAkJCS8qIEZBTEwgVEhST1VHSCAq
Lw0KIAkJICAgICAgZGVmYXVsdDoNCg==

------_=_NextPart_001_01C465E5.05A08D57--
