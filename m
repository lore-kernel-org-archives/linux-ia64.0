From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 19 Nov 2002 18:35:44 +0000
Subject: RE: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C28FFA.7840BE75"
Message-Id: <marc-linux-ia64-105590709805461@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805337@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C28FFA.7840BE75
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Here is the updated patch against current glibc cvs strncpy.S v1.9.

There are two hunks in this patch.  The first hunk initialize ar.ec, ec =
is not guaranteed to be zero upon function entry, although most likely =
it will be zero.  But such assumption is functionally broken.

The second hunk fixes the seg fault in recovery 4 section.  The case of =
seg fault is that when src length ends exactly at a page boundary, and =
there are no mapping after that page.  In recovery 4, it is trying to =
access an invalid address due to earlier loop that src pointer got post =
incremented pass beyond current page.

- Ken


-----Original Message-----
From: Randolph Chung [mailto:randolph@tausq.org]
Sent: Tuesday, November 19, 2002 8:19 AM
To: Chen, Kenneth W
Cc: bug-glibc@gnu.org; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] IA64 strncpy in 2.2.4-30 - bug and patch


In reference to a message from Chen, Kenneth W, dated Nov 07:
> We found more bugs in the code, and here is an updated patch to fix =
them.
> Note this patch supercedes the one I sent yesterday.
>=20
> Also attached is the test program we used to verify the fix.

Is there an updated version of this that applies against glibc cvs? Or
is the one Jakub/Roland checked in sufficient (it looks more like the =
first
version you posted)

thanks,
randolph
--=20
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

------_=_NextPart_001_01C28FFA.7840BE75
Content-Type: application/octet-stream;
	name="strncpy.fix.cvs_v1.9"
Content-Transfer-Encoding: base64
Content-Description: strncpy.fix.cvs_v1.9
Content-Disposition: attachment;
	filename="strncpy.fix.cvs_v1.9"

LS0tIHN0cm5jcHkuUy5vcmlnCVR1ZSBOb3YgMTkgMTA6MjI6MDEgMjAwMgorKysgc3RybmNweS5T
CVR1ZSBOb3YgMTkgMTA6Mjk6MjEgMjAwMgpAQCAtNjMsNiArNjMsNyBAQAogCW1vdglzYXZlZF9w
ciA9IHByICAgICAgICAgICAvLyBzYXZlIHRoZSBwcmVkaWNhdGUgcmVnaXN0ZXJzCiAJLnNhdmUg
YXIubGMsIHNhdmVkX2xjCiAJbW92IAlzYXZlZF9sYyA9IGFyLmxjCS8vIHNhdmUgdGhlIGxvb3Ag
Y291bnRlcgorCW1vdglhci5lYyA9IDAKIAkuYm9keQogCWNtcC5nZXUgcDYsIHA1ID0gMjQsIGlu
MgogKHA2KQlici5jb25kLnNwbnQgLnNob3J0X2xlbgpAQCAtMjIxLDcgKzIyMiw5IEBACiAJbGQ4
CXJbTUVNTEFUXSA9IFt0bXBdCiAJYnIuY29uZC5zcHRrIC5iYWNrMwogLnJlY292ZXJ5NDoKKwlj
bXAuZXEJcDgscDk9MCxsZW4KIAlhZGQJdG1wID0gLU1FTUxBVCAqIDgsIHNyYyA7OwotCWxkOAly
W01FTUxBVCAtIDFdID0gW3RtcF0KKyhwOCkJbW92CXJbTUVNTEFUIC0gMV0gPSByMAorKHA5KQls
ZDgJcltNRU1MQVQgLSAxXSA9IFt0bXBdCiAJYnIuY29uZC5zcHRrIC5iYWNrNAogRU5EKHN0cm5j
cHkpCg==

------_=_NextPart_001_01C28FFA.7840BE75--

