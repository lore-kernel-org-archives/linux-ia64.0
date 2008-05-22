From: "Luming Yu" <luming.yu@gmail.com>
Date: Thu, 22 May 2008 02:47:35 +0000
Subject: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_8753_10367779.1211424456021"
List-Id: <linux-ia64.vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

------=_Part_8753_10367779.1211424456021
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list,

The following patch is to fixed a race in ptrace_stop handling which
causes "strace" hang if the target process blocks SIGTRAP with the
test case filed at
https://bugzilla.redhat.com/show_bug.cgi?id=446200#c16.
Please note this is just IA64 problem because just IA64 has
arch_ptrace_stop_needed defined, and has arch_ptrace_stop defined that
would set notify_resume flags for syncing rbs...but it also opens the
door to invoke ia64_do_signal->get_signal_to_deliver before setting
current PTRACED flag. Please help review.

**The patch is enclosed in text attachment*
**I'm using web client to send the patch* *

Signed-off-by: Yu Luming <luming.yu@intel.com>
--------------------------------------
 signal.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

------=_Part_8753_10367779.1211424456021
Content-Type: application/force-download; name=446200.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fgiqpxnr0
Content-Disposition: attachment; filename=446200.patch

LS0tIDAva2VybmVsL3NpZ25hbC5jCTIwMDgtMDUtMTQgMDI6MjQ6NTEuMDAwMDAwMDAwICswODAw
CisrKyAxL2tlcm5lbC9zaWduYWwuYwkyMDA4LTA1LTIyIDEzOjU0OjQyLjAwMDAwMDAwMCArMDgw
MApAQCAtMTQ4OCw2ICsxNDg4LDkgQEAKIHsKIAlpbnQga2lsbGVkID0gMDsKIAorCS8qIExldCB0
aGUgZGVidWdnZXIgcnVuLiAgKi8KKwlfX3NldF9jdXJyZW50X3N0YXRlKFRBU0tfVFJBQ0VEKTsK
KwogCWlmIChhcmNoX3B0cmFjZV9zdG9wX25lZWRlZChleGl0X2NvZGUsIGluZm8pKSB7CiAJCS8q
CiAJCSAqIFRoZSBhcmNoIGNvZGUgaGFzIHNvbWV0aGluZyBzcGVjaWFsIHRvIGRvIGJlZm9yZSBh
CkBAIC0xNTE2LDggKzE1MTksNiBAQAogCWN1cnJlbnQtPmxhc3Rfc2lnaW5mbyA9IGluZm87CiAJ
Y3VycmVudC0+ZXhpdF9jb2RlID0gZXhpdF9jb2RlOwogCi0JLyogTGV0IHRoZSBkZWJ1Z2dlciBy
dW4uICAqLwotCV9fc2V0X2N1cnJlbnRfc3RhdGUoVEFTS19UUkFDRUQpOwogCXNwaW5fdW5sb2Nr
X2lycSgmY3VycmVudC0+c2lnaGFuZC0+c2lnbG9jayk7CiAJcmVhZF9sb2NrKCZ0YXNrbGlzdF9s
b2NrKTsKIAlpZiAoIXVubGlrZWx5KGtpbGxlZCkgJiYgbWF5X3B0cmFjZV9zdG9wKCkpIHsK
------=_Part_8753_10367779.1211424456021--
