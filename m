From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 07 Nov 2002 02:56:52 +0000
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C28609.531ACE7A"
Message-Id: <marc-linux-ia64-105590709805346@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805337@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C28609.531ACE7A
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

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

------_=_NextPart_001_01C28609.531ACE7A
Content-Type: application/octet-stream;
	name="strncpy.fix.patch"
Content-Transfer-Encoding: base64
Content-Description: strncpy.fix.patch
Content-Disposition: attachment;
	filename="strncpy.fix.patch"

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
cmVjb3ZlcnkyOg0KKwlzdWIJdG1wMj1sZW4sdGhyZXNoDQorCTs7DQorCWNtcC5lcQlwOCxwOT0t
OCwgdG1wMg0KIAlhZGQJdG1wID0gLTgsIGFzcmMgOzsNCi0JbGQ4CXJbMF0gPSBbdG1wXQ0KKyhw
OCkJbW92CXJbMF0gPSByMA0KKyhwOSkJbGQ4CXJbMF0gPSBbdG1wXQ0KIAlici5jb25kLnNwdGsg
LmJhY2syDQogLnJlY292ZXJ5MzoNCi0JYWRkCXRtcCA9IC1NRU1MQVQgKiA4LCBzcmMgOzsNCisJ
YWRkCXRtcCA9IC0oTUVNTEFUKzEpICogOCwgc3JjIDs7DQogCWxkOAlyW01FTUxBVF0gPSBbdG1w
XQ0KIAlici5jb25kLnNwdGsgLmJhY2szDQogLnJlY292ZXJ5NDoNCi0JYWRkCXRtcCA9IC0oTUVN
TEFUIC0gMSkgKiA4LCBzcmMgOzsNCi0JbGQ4CXJbTUVNTEFUIC0gMV0gPSBbdG1wXQ0KKwljbXAu
ZXEJcDgscDk9MCwgbGVuDQorCWFkZAl0bXAgPSAtKE1FTUxBVCkgKiA4LCBzcmMgOzsNCisocDgp
CW1vdglyW01FTUxBVCAtIDFdID0gcjANCisocDkpCWxkOAlyW01FTUxBVCAtIDFdID0gW3RtcF0N
CiAJYnIuY29uZC5zcHRrIC5iYWNrNA0KIEVORChzdHJuY3B5KQ0K

------_=_NextPart_001_01C28609.531ACE7A--

