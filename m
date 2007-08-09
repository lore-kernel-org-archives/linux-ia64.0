From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 09 Aug 2007 06:30:09 +0000
Subject: need NOTES in vmlinux.lds.S
Message-Id: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_125990_11882518.1186641009080"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_125990_11882518.1186641009080
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Without the attached patch, the current GIT trees fail to build for me
with error:

 ld: .tmp_vmlinux1: section `.text' can't be allocated in segment 0
 ld: final link failed: Bad value

This is with binutils v2.17.50.20070804 and is apparently due to the
recent --build-id changes (see
http://www.uwsg.indiana.edu/hypermail/linux/kernel/0707.2/3490.html).

I may not have picked the best possible place to stick the NOTES macro
(according to Roland, it should only be a few read-only bytes that are
hardly ever read), but at least the kernel builds again and it even
seems to boot (on my zx2000, anyhow). ;-)

Thanks to HJ Lu for his help in tracking down this bug.

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/

------=_Part_125990_11882518.1186641009080
Content-Type: text/plain; name=notes.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f54vdver
Content-Disposition: attachment; filename="notes.diff"

W0lBNjRdIEFkZCBOT1RFUyB0byBsaW5rZXIgc2NyaXB0IHN1Y2ggdGhhdCB0aGUga2VybmVsIGNh
biBiZSBidWlsdCB3aXRoCiAgICAgICByZWNlbnQgdmVyc2lvbnMgb2YgYmludXRpbHMuICBXaXRo
b3V0IHRoaXMgcGF0Y2gsIGZpbmFsIGxpbmsgZmFpbHMKICAgICAgIHdpdGggdGhpcyBlcnJvcjoK
CiAgICAgICAgbGQ6IC50bXBfdm1saW51eDE6IHNlY3Rpb24gYC50ZXh0JyBjYW4ndCBiZSBhbGxv
Y2F0ZWQgaW4gc2VnbWVudCAwCiAgICAgICAgbGQ6IGZpbmFsIGxpbmsgZmFpbGVkOiBCYWQgdmFs
dWUKCiAgICAgICBUaGlzIGVycm9yIGlzIGR1ZSB0byB0aGUgZmFjdCB0aGF0IHRoZSAtLWJ1aWxk
LWlkIG9wdGlvbiBpcyB1c2VkCiAgICAgICB3aXRoIG5ld2VyIGxpbmtlcnMgdG8gaW5jbHVkZSBh
IC5ub3RlcyBzZWN0aW9uIG9uIHRoZSBrZXJuZWwsIGJ1dAogICAgICAgd2l0aG91dCB0aGUgTk9U
RVMgbWFjcm8sIHRoYXQgc2VjdGlvbiB3b24ndCBiZSBpbmNsdWRlZCBpbiB0aGUga2VybmVsCiAg
ICAgICB3aGljaCB0aGVuIGxlYWRzIHRvIHRoZSBhYm92ZSBlcnJvciBtZXNzYWdlLgoKU2lnbmVk
LW9mZi1ieTogRGF2aWQgTW9zYmVyZ2VyLVRhbmcgPGRtb3NiZXJnZXJAZ21haWwuY29tPgoKZGlm
ZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5sZHMuUyBiL2FyY2gvaWE2NC9rZXJu
ZWwvdm1saW51eC5sZHMuUwppbmRleCA4M2U4MDY3Li43MWViNTUwIDEwMDY0NAotLS0gYS9hcmNo
L2lhNjQva2VybmVsL3ZtbGludXgubGRzLlMKKysrIGIvYXJjaC9pYTY0L2tlcm5lbC92bWxpbnV4
Lmxkcy5TCkBAIC02Miw2ICs2Miw4IEBAIFNFQ1RJT05TCiAKICAgLyogUmVhZC1vbmx5IGRhdGEg
Ki8KIAorICBOT1RFUworCiAgIC8qIEV4Y2VwdGlvbiB0YWJsZSAqLwogICAuID0gQUxJR04oMTYp
OwogICBfX2V4X3RhYmxlIDogQVQoQUREUihfX2V4X3RhYmxlKSAtIExPQURfT0ZGU0VUKQo=
------=_Part_125990_11882518.1186641009080--
