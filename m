From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 07 Nov 2002 19:10:27 +0000
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C28691.5552280D"
Message-Id: <marc-linux-ia64-105590709805354@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805337@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C28691.5552280D
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We found more bugs in the code, and here is an updated patch to fix =
them.
Note this patch supercedes the one I sent yesterday.

Also attached is the test program we used to verify the fix.

- Ken Chen


-----Original Message-----
From: Chen, Kenneth W=20
Sent: Wednesday, November 06, 2002 6:57 PM
To: Chen, Kenneth W; Reese Faucette; bug-glibc@gnu.org;
linux-ia64@linuxia64.org
Cc: Akyil, Levent; susan@myri.com; Mallick, Asit K
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch


Here is a patch that fixes bugs in strncpy function included in =
glibc-2.2.4.  We found there are more bugs during the investigation.  =
Please pound on this patch and let us know any issues.

- Ken Chen


-----Original Message-----
From: Chen, Kenneth W=20
Sent: Tuesday, November 05, 2002 4:44 PM
To: Reese Faucette; bug-glibc@gnu.org; linux-ia64@linuxia64.org
Cc: Akyil, Levent; susan@myri.com
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch


I'm not able to reproduce the bug with your test case ...

-----Original Message-----
From: Reese Faucette [mailto:reese@myri.com]
Sent: Tuesday, November 05, 2002 4:39 PM
To: bug-glibc@gnu.org; linux-ia64@linuxia64.org
Cc: Akyil, Levent; susan@myri.com
Subject: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch


Hi,
I opened a bug with RedHat about a problem with strncpy() in =
glibc-2.2.4-30 on IA64, see =
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D76952, but I've =
been told you folks are really the ones to talk to.
=20
The bug report contains a testcase illustrating the problem, and also a =
patch.  In short, the recovery code is busted, even after the patch from =
David Mosberger.  Attached is a copy of the patch from the bug report.
=20
I have a testcase which exercizes both the recovery3 and recovery4 paths =
if you're interested. =20
Regards,
-reese faucette
=20
=20


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

------_=_NextPart_001_01C28691.5552280D
Content-Type: application/octet-stream;
	name="strncpy2.fix.patch"
Content-Transfer-Encoding: base64
Content-Description: strncpy2.fix.patch
Content-Disposition: attachment;
	filename="strncpy2.fix.patch"

LS0tIHN0cm5jcHkuUy5vcmlnCVdlZCBOb3YgIDYgMTc6MTY6MzEgMjAwMg0KKysrIHN0cm5jcHku
UwlXZWQgTm92ICA2IDE4OjQ3OjI1IDIwMDINCkBAIC00OCw2ICs0OCw3IEBADQogI2RlZmluZQlz
aDEJCXIyOQ0KICNkZWZpbmUgbG9vcGNudAkJcjMwDQogI2RlZmluZQl2YWx1ZQkJcjMxDQorI2Rl
ZmluZSB0bXAyCQlyMTQNCiANCiBFTlRSWShzdHJuY3B5KQ0KIAkucHJvbG9ndWUNCkBAIC02Miw2
ICs2Myw3IEBADQogCW1vdglzYXZlZF9wciA9IHByICAgICAgICAgICAvLyBzYXZlIHRoZSBwcmVk
aWNhdGUgcmVnaXN0ZXJzDQogCS5zYXZlIGFyLmxjLCBzYXZlZF9sYw0KIAltb3YgCXNhdmVkX2xj
ID0gYXIubGMJLy8gc2F2ZSB0aGUgbG9vcCBjb3VudGVyDQorCW1vdglhci5lYyA9IDANCiAJLmJv
ZHkNCiAJY21wLmdldSBwNiwgcDUgPSAyNCwgaW4yDQogKHA2KQlici5jb25kLnNwbnQgLnNob3J0
X2xlbg0KQEAgLTIwOSwxNSArMjExLDIxIEBADQogCW1vdglwciA9IHNhdmVkX3ByLCAtMQkvLyBy
ZXN0b3JlIHRoZSBwcmVkaWNhdGUgcmVnaXN0ZXJzDQogCWJyLnJldC5zcHRrLm1hbnkgYjANCiAu
cmVjb3ZlcnkyOg0KKwlzdWIJdG1wMj1sZW4sdGhyZXNoDQorCTs7DQorCWNtcC5nZQlwOCxwOT0t
OCwgdG1wMg0KIAlhZGQJdG1wID0gLTgsIGFzcmMgOzsNCi0JbGQ4CXJbMF0gPSBbdG1wXQ0KKyhw
OCkJbW92CXJbMF0gPSByMA0KKyhwOSkJbGQ4CXJbMF0gPSBbdG1wXQ0KIAlici5jb25kLnNwdGsg
LmJhY2syDQogLnJlY292ZXJ5MzoNCi0JYWRkCXRtcCA9IC1NRU1MQVQgKiA4LCBzcmMgOzsNCisJ
YWRkCXRtcCA9IC0oTUVNTEFUKzEpICogOCwgc3JjIDs7DQogCWxkOAlyW01FTUxBVF0gPSBbdG1w
XQ0KIAlici5jb25kLnNwdGsgLmJhY2szDQogLnJlY292ZXJ5NDoNCi0JYWRkCXRtcCA9IC0oTUVN
TEFUIC0gMSkgKiA4LCBzcmMgOzsNCi0JbGQ4CXJbTUVNTEFUIC0gMV0gPSBbdG1wXQ0KKwljbXAu
ZXEJcDgscDk9MCwgbGVuDQorCWFkZAl0bXAgPSAtKE1FTUxBVCkgKiA4LCBzcmMgOzsNCisocDgp
CW1vdglyW01FTUxBVCAtIDFdID0gcjANCisocDkpCWxkOAlyW01FTUxBVCAtIDFdID0gW3RtcF0N
CiAJYnIuY29uZC5zcHRrIC5iYWNrNA0KIEVORChzdHJuY3B5KQ0K

------_=_NextPart_001_01C28691.5552280D
Content-Type: application/octet-stream;
	name="bug.c"
Content-Transfer-Encoding: base64
Content-Description: bug.c
Content-Disposition: attachment;
	filename="bug.c"

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8c3RkbGli
Lmg+DQojaW5jbHVkZSA8c3lzL3NobS5oPg0KDQojZGVmaW5lIE1DUFlTSVpFIDIwNDgNCg0KZXh0
ZXJuIGNoYXIgKm15X3N0cm5jcHkoY2hhciAqZGVzdCwgY29uc3QgY2hhciAqc3JjLCBzaXplX3Qg
bik7DQoNCmludCBtYWluKCkNCnsNCiAgbG9uZyBidWZmZXJbTUNQWVNJWkVdOw0KDQogIGludCBp
LCBqLCBrLCB4Ow0KICBjaGFyICpzcmMsICpkc3Q7DQogIHNpemVfdCBsZW47DQogIGludCBzaG1p
ZDsNCiAgY2hhciogc2htYWRkcjsNCg0KDQogIHNobWlkID0gc2htZ2V0KDEsIDE2Mzg0LCBJUENf
Q1JFQVR8U0hNX1J8U0hNX1cpOw0KICBzaG1hZGRyID0gKGNoYXIqKSBzaG1hdChzaG1pZCwgTlVM
TCwgU0hNX1JORCk7DQoNCiAgZm9yIChpPTA7IGk8MTYzODQ7IGkrKykNCiAgICBzaG1hZGRyW2ld
ID0gaTsNCg0KICBkc3QgPSAoY2hhciopIGJ1ZmZlcjsNCg0KICBmb3IgKGs9MTsgazwxMDAwOyBr
Kz0xKQ0KICAgIGZvciAoaT0wOyBpPDg7IGkrKykNCiAgICAgIGZvciAoaj0wOyBqPDg7IGorKykg
ew0KDQoJc3JjID0gKGNoYXIqKSBzaG1hZGRyICsgMTYzODQgLSBrIC0gaTsNCglkc3QgPSAoY2hh
ciopIGJ1ZmZlciArIGo7DQoJbGVuICA9IGs7DQoNCi8vCXByaW50ZigiZHN0ICVwIHNyYyAlcCBu
ICU0ZFxuIiwgZHN0LCBzcmMsIGxlbik7DQoJbXlfc3RybmNweShkc3QsIHNyYywgbGVuKTsNCg0K
CWZvciAoeD0wOyB4PGxlbjsgeCsrKSB7DQoJCWlmIChzcmNbeF0gPT0gMCkgYnJlYWs7DQoJCWlm
ICggZHN0W3hdICE9IHNyY1t4XSApIHsNCgkJCXVuc2lnbmVkIGxvbmcgKiBsX3NyYyA9ICh1bnNp
Z25lZCBsb25nKikgKCh1bnNpZ25lZCBsb25nKSAmc3JjW3hdICYgLTgpOw0KCQkJdW5zaWduZWQg
bG9uZyAqIGxfZHN0ID0gKHVuc2lnbmVkIGxvbmcqKSAoKHVuc2lnbmVkIGxvbmcpICZkc3RbeF0g
JiAtOCk7DQoNCgkJCXByaW50ZigiZXJyb3JcdCIpOw0KCQkJcHJpbnRmKCJkc3QgJXAgc3JjICVw
IG4gJTRkXG4iLCBkc3QsIHNyYywgbGVuKTsNCg0KCQkJcHJpbnRmKCIlZDogJXggJXhcbiIsIHgs
IGRzdFt4XSwgc3JjW3hdKTsNCg0KCQkJcHJpbnRmKCIlZDogJTE2eCAlMTZ4XG4iLCB4LCAqbF9k
c3QsICpsX3NyYyk7DQoJCQlleGl0KDApOw0KLy8JCQlicmVhazsNCgkJfQ0KCX0NCg0KLy8JaWYg
KHN0cmNtcChkc3QsIHNyYywgbGVuKSAhPSAwKQ0KLy8JICBwcmludGYoImJ1ZyBmb3VuZFxuIik7
DQoNCiAgICAgIH0gLy8gZm9yIChqPTAgLi4uDQoNCiAgc2htZHQoc2htYWRkcik7DQogIHNobWN0
bChzaG1pZCwgSVBDX1JNSUQsIE5VTEwpOw0KfQ0K

------_=_NextPart_001_01C28691.5552280D
Content-Type: application/octet-stream;
	name="bug2.c"
Content-Transfer-Encoding: base64
Content-Description: bug2.c
Content-Disposition: attachment;
	filename="bug2.c"

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8c3RkbGli
Lmg+DQojaW5jbHVkZSA8c3lzL3NobS5oPg0KI2luY2x1ZGUgPHN5cy9tbWFuLmg+DQojaW5jbHVk
ZSA8dW5pc3RkLmg+DQojaW5jbHVkZSA8ZmNudGwuaD4NCg0KI2RlZmluZSBNQ1BZU0laRSAyMDQ4
DQoNCmV4dGVybiBjaGFyICpteV9zdHJuY3B5KGNoYXIgKmRlc3QsIGNvbnN0IGNoYXIgKnNyYywg
c2l6ZV90IG4pOw0KDQppbnQgbWFpbigpDQp7DQogIGxvbmcgYnVmZmVyW01DUFlTSVpFXTsNCg0K
ICBpbnQgaSwgaiwgaywgbCwgeDsNCiAgY2hhciAqc3JjLCAqZHN0Ow0KICBzaXplX3QgbGVuOw0K
ICBpbnQgc2htaWQ7DQogIGNoYXIqIHNobWFkZHI7DQogIGludCBmZDsNCg0KLyoNCiAgc2htaWQg
PSBzaG1nZXQoMSwgMTYzODQsIElQQ19DUkVBVHxTSE1fUnxTSE1fVyk7DQogIHNobWFkZHIgPSAo
Y2hhciopIHNobWF0KHNobWlkLCBOVUxMLCBTSE1fUk5EKTsNCiovDQogIGZkID0gb3BlbigiZGF0
YSIsIE9fUkRPTkxZKTsNCg0KICBkc3QgPSAoY2hhciopIGJ1ZmZlcjsNCg0KICBmb3IgKGs9MDsg
azwxMDAwMDsgays9MSkNCiAgIGZvciAobD0wOyBsPDEwOyBsKyspDQogICAgZm9yIChpPTA7IGk8
ODsgaSsrKQ0KICAgICAgZm9yIChqPTA7IGo8ODsgaisrKSB7DQoNCiAgc2htYWRkciA9IChjaGFy
KikgbW1hcChOVUxMLCAxNjM4NCoyLCBQUk9UX1JFQUQsIE1BUF9TSEFSRUQsIGZkLCAwKTsNCiAg
aWYgKHNobWFkZHIgPT0gTlVMTCkgcGVycm9yKCJ6ZXJvIGFkZHJlc3MiKTsNCg0KCXNyYyA9IChj
aGFyKikgc2htYWRkciArIDE2Mzg0IC0gayAtIGk7DQoJZHN0ID0gKGNoYXIqKSBidWZmZXIgKyBq
Ow0KCWxlbiAgPSBrK2w7DQoNCi8vCXByaW50ZigiZHN0ICVwIHNyYyAlcCBuICU0ZFxuIiwgZHN0
LCBzcmMsIGxlbik7DQoJbXlfc3RybmNweShkc3QsIHNyYywgbGVuKTsNCg0KCWZvciAoeD0wOyB4
PGxlbjsgeCsrKSB7DQoJCWlmIChzcmNbeF0gPT0gMCkgYnJlYWs7DQoJCWlmICggZHN0W3hdICE9
IHNyY1t4XSApIHsNCgkJCXVuc2lnbmVkIGxvbmcgKiBsX3NyYyA9ICh1bnNpZ25lZCBsb25nKikg
KCh1bnNpZ25lZCBsb25nKSAmc3JjW3hdICYgLTgpOw0KCQkJdW5zaWduZWQgbG9uZyAqIGxfZHN0
ID0gKHVuc2lnbmVkIGxvbmcqKSAoKHVuc2lnbmVkIGxvbmcpICZkc3RbeF0gJiAtOCk7DQoNCgkJ
CXByaW50ZigiZXJyb3JcdCIpOw0KCQkJcHJpbnRmKCJkc3QgJXAgc3JjICVwIG4gJTRkXG4iLCBk
c3QsIHNyYywgbGVuKTsNCg0KCQkJcHJpbnRmKCIlZDogJXggJXhcbiIsIHgsIGRzdFt4XSwgc3Jj
W3hdKTsNCg0KCQkJcHJpbnRmKCIlZDogJTE2eCAlMTZ4XG4iLCB4LCAqbF9kc3QsICpsX3NyYyk7
DQovLwkJCWV4aXQoMCk7DQovLwkJCWJyZWFrOw0KCQl9DQoJfQ0KDQogIG11bm1hcChzaG1hZGRy
LCAxNjM4NCoyKTsNCg0KICAgICAgfSAvLyBmb3IgKGo9MCAuLi4NCn0NCg==

------_=_NextPart_001_01C28691.5552280D--

