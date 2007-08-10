From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Fri, 10 Aug 2007 01:58:52 +0000
Subject: get back PT_IA_64_UNWIND program header
Message-Id: <ed5aea430708091858s352ed254p22cb7a7ae70209@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_136580_191254.1186711132453"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_136580_191254.1186711132453
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I noticed that Ski was unable to do a stacktrace on the kernel.  Turns
out that's because the PT_IA_64_UNWIND program-header is missing.
Perhaps this is due to a change in binutils, but in any case, it seems
like we should be explicit about the unwind header, so this patch is
probably a good idea no matter what.  Note that the patch assumes that
the earlier patch to add a PT_NOTE header has been applied already.

Regards,

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_136580_191254.1186711132453
Content-Type: text/plain; name=pt_unwind.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f56154u5
Content-Disposition: attachment; filename="pt_unwind.diff"

W0lBNjRdIEV4cGxpY2l0bHkgcHV0IHRoZSB1bndpbmQgc2VjdGlvbiBpbnRvIGl0cyBvd24gcHJv
Z3JhbS1oZWFkZXIuICBUaGlzCiAgICAgICB1c2VkIHRvIGJlIHVubmVjZXNzYXJ5IChwcm9iYWJs
eSBiZWNhdXNlIGJpbnV0aWxzIGRpZCBpdCBmb3IgdXMpLCBidXQKICAgICAgIHdpdGggY3VycmVu
dCBiaW51dGlscyAoZS5nLiwgdjIuMTcuNTAuMjAwNzA4MDQpIHdlIHdvbid0IGdldAogICAgICAg
dGhlIFBUX0lBXzY0X1VOV0lORCBoZWFkZXIgd2l0aG91dCB0aGlzIHBhdGNoIHdoaWNoIHdpbGwg
YnJlYWsKICAgICAgIHVud2luZGluZyBpbiBhIGRlYnVnZ2VyIGFuZCBzaW11bGF0b3JzIHN1Y2gg
YXMgU2tpLgoKU2lnbmVkLW9mZi1ieTogRGF2aWQgTW9zYmVyZ2VyLVRhbmcgPGRtb3NiZXJnZXJA
Z21haWwuY29tPgoKLS0tIGFyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5sZHMuU34JMjAwNy0wOC0w
OSAxMTozODoyOC4wMDAwMDAwMDAgLTA2MDAKKysrIGFyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5s
ZHMuUwkyMDA3LTA4LTA5IDE5OjQwOjA4LjAwMDAwMDAwMCAtMDYwMApAQCAtMjEsNiArMjEsNyBA
QAogICBwZXJjcHUgUFRfTE9BRDsKICAgZGF0YSAgIFBUX0xPQUQ7CiAgIG5vdGUgICBQVF9OT1RF
OworICB1bndpbmQgMHg3MDAwMDAwMTsgLyogUFRfSUFfNjRfVU5XSU5ELCBidXQgbGQgZG9lc24n
dCBtYXRjaCB0aGUgbmFtZSAqLwogfQogU0VDVElPTlMKIHsKQEAgLTEwMyw3ICsxMDQsOCBAQAog
CSAgX19zdGFydF91bndpbmQgPSAuOwogCSAgKiguSUFfNjQudW53aW5kKikKIAkgIF9fZW5kX3Vu
d2luZCA9IC47Ci0JfQorCX0gOmNvZGUgOnVud2luZAorICBjb2RlX2NvbnRpbnVlczIgOiB7fSA6
IGNvZGUKIAogICBST0RBVEEKIAo=
------=_Part_136580_191254.1186711132453--
