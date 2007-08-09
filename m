From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 09 Aug 2007 22:54:27 +0000
Subject: trivial boot_head.S
Message-Id: <ed5aea430708091554h452fc0d7t2e47bfaeec5bf02d@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_135400_2080533.1186700067869"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_135400_2080533.1186700067869
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Attached is a trivial patch that makes stack-unwinding stop at the
last frame of the bootloader.

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_135400_2080533.1186700067869
Content-Type: text/plain; name=boot_head.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f55ukenp
Content-Disposition: attachment; filename="boot_head.diff"

W0lBNjRdIEFkZCBhIGR1bW15IG5vcCBhdCB0aGUgZW5kIG9mIF9zdGFydCgpIHRvIG1haW50YWlu
IHRoZSBpbnZhcmlhbnQgdGhhdAogICAgICAgdGhlIHJldHVybi1wb2ludGVyIChycCkgYWx3YXlz
IHBvaW50IHRvIHRoZSBjYWxsaW5nIGZ1bmN0aW9uLiAgVGhpcwogICAgICAgbWFrZXMgdW53aW5k
aW5nIHN0b3AgYXQgdGhlIGxhc3QgZnJhbWUsIGFzIGl0IHNob3VsZC4KClNpZ25lZC1vZmYtYnk6
IERhdmlkIE1vc2Jlcmdlci1UYW5nIDxkbW9zYmVyZ2VyQGdtYWlsLmNvbT4KCmRpZmYgLS1naXQg
YS9hcmNoL2lhNjQvaHAvc2ltL2Jvb3QvYm9vdF9oZWFkLlMgYi9hcmNoL2lhNjQvaHAvc2ltL2Jv
b3QvYm9vdF9oZWFkLlMKaW5kZXggYTliZDcxYS4uODgwODU2NSAxMDA2NDQKLS0tIGEvYXJjaC9p
YTY0L2hwL3NpbS9ib290L2Jvb3RfaGVhZC5TCisrKyBiL2FyY2gvaWE2NC9ocC9zaW0vYm9vdC9i
b290X2hlYWQuUwpAQCAtMjYsNiArMjYsNyBAQCBHTE9CQUxfRU5UUlkoX3N0YXJ0KQogCW1vdmwg
c3AgPSBzdGFja19tZW0rMTYzODQtMTYKIAlic3cuMQogCWJyLmNhbGwuc3B0ay5tYW55IHJwPXN0
YXJ0X2Jvb3Rsb2FkZXIKKzA6CW5vcCAwCQkgIC8qIGR1bW15IG5vcCB0byBtYWtlIHVud2luZGlu
ZyB3b3JrICovCiBFTkQoX3N0YXJ0KQogCiAvKgo=
------=_Part_135400_2080533.1186700067869--
