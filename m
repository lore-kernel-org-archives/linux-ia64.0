From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Feb 2005 06:57:08 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02E2C999@scsmsx401.amr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C51006.E822CBF4"
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C51006.E822CBF4
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


>No real additional information.  It still fails with the latest=20
>release-2.6.11 tree.  It sometimes recovers once or twice, but
>not more than that.  Something is getting trashed or not restored
>correctly.  At least it is easily reproduceable, which makes=20
>problems much easier to track down.

I've established that the scratch FP registers need to be saved, but
nobody is doing that.

Attached (untested) patch does that (not paticularly elegantly, but
should be functional).

-Tony

------_=_NextPart_001_01C51006.E822CBF4
Content-Type: application/octet-stream;
	name="fpsave.patch"
Content-Transfer-Encoding: base64
Content-Description: fpsave.patch
Content-Disposition: attachment;
	filename="fpsave.patch"

PT09PT0gYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMgMS4yMCB2cyBlZGl0ZWQgPT09PT0KLS0t
IDEuMjAvYXJjaC9pYTY0L2tlcm5lbC9tY2FfYXNtLlMJMjAwNS0wMi0wOCAwOTo1Nzo1OSAtMDg6
MDAKKysrIGVkaXRlZC9hcmNoL2lhNjQva2VybmVsL21jYV9hc20uUwkyMDA1LTAyLTEwIDE3OjA0
OjUyIC0wODowMApAQCAtNTk5LDYgKzU5OSwxNSBAQAogCWFkZAkJcjQ9MSxyNAogCWJyLmNsb29w
LnNwdGsuZmV3CWNTdFJSCiAJOzsKKworLy8gc2F2ZSBzY3JhdGNoIEZQIHJlZ3MKKwlzdGYuc3Bp
bGwgW3IyXT1mNiwxNjs7CisJc3RmLnNwaWxsIFtyMl09ZjcsMTY7OworCXN0Zi5zcGlsbCBbcjJd
PWY4LDE2OzsKKwlzdGYuc3BpbGwgW3IyXT1mOSwxNjs7CisJc3RmLnNwaWxsIFtyMl09ZjEwLDE2
OzsKKwlzdGYuc3BpbGwgW3IyXT1mMTEsMTY7OworCiBlbmRfb3NfbWNhX2R1bXA6CiAJYnIJaWE2
NF9vc19tY2FfZG9uZV9kdW1wOzsKIApAQCAtODM0LDYgKzg0MywxNSBAQAogCTs7CiAJbW92CQlh
ci5sYz1yNQogCTs7CisKKy8vIHJlc3RvcmUgc2NyYXRjaCBGUCByZWdzCisJbGRmLmZpbGwJZjY9
W3IyXSwxNjs7CisJbGRmLmZpbGwJZjc9W3IyXSwxNjs7CisJbGRmLmZpbGwJZjg9W3IyXSwxNjs7
CisJbGRmLmZpbGwJZjk9W3IyXSwxNjs7CisJbGRmLmZpbGwJZjEwPVtyMl0sMTY7OworCWxkZi5m
aWxsCWYxMT1bcjJdLDE2OzsKKwogZW5kX29zX21jYV9yZXN0b3JlOgogCWJyCWlhNjRfb3NfbWNh
X2RvbmVfcmVzdG9yZTs7CiAK

------_=_NextPart_001_01C51006.E822CBF4--
