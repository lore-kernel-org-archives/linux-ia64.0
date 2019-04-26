From: Adam Richter <adamrichter4@gmail.com>
Date: Fri, 26 Apr 2019 20:51:42 +0000
Subject: [Untested patch] Suspected null pointer dereference in ftrace_make_nop() for ia64
Message-Id: <CAGn-Tgg9qOoFNKKrbK1=XQEKj8wwD26NWY+1G4cDHRySsJWcYQ@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="000000000000c7c79f0587751a3c"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--000000000000c7c79f0587751a3c
Content-Type: text/plain; charset="UTF-8"

Hi.

In arch/ia64/kernel/trace.c, ftrace_make_nop() apparently can call
ftrace_modify_code() with second parameter (old_code) set to NULL,
which ftrace_make_nop can dereference.  I have attached an appended an
untested patch which I think should cause ftrace_modify_code to avoid
the pointer dereference when old_code is null.

I am not an Itanium developer or user but just want to submit what I
think is a fix for a bug that cppcheck pointed me to.  I have not even
tried to compile with this patch.  So, please feel free to replace
this with a patch more to your liking.

It has been a long time since I tried to submit a Linux kernel patch,
so I am not up to date on the latest process requirements.  I hereby
release my copyright interest in this patch to the public domain and
state that, to the best of my knowledge, my contribution does not add
anyone else's copyright interests or other intellectual property.
This contribution should not be taken to imply my agreement,
disagreement or making of any "pledge" with respect to any "code of
conduct" or other terms.  If you need me to make some other statement
or do something else, please just let me know.

Thanks in advance for considering this patch.

Adam Richter

diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index 7fc8c961b1f7..98085dcbf20a 100644
--- a/arch/ia64/kernel/ftrace.c
+++ b/arch/ia64/kernel/ftrace.c
@@ -114,7 +114,8 @@ ftrace_modify_code(unsigned long ip, unsigned char
*old_code,
                return -EFAULT;

        /* Make sure it is what we expect it to be */
-       if (memcmp(replaced, old_code, MCOUNT_INSN_SIZE) != 0)
+       if (old_code != NULL &&
+           memcmp(replaced, old_code, MCOUNT_INSN_SIZE) != 0)
                return -EINVAL;

 skip_check:

--000000000000c7c79f0587751a3c
Content-Type: text/x-diff; charset="US-ASCII"; 
	name="ia64_ftrace_make_nop_null_ptr_fault.diff"
Content-Disposition: attachment; 
	filename="ia64_ftrace_make_nop_null_ptr_fault.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_juyj59yr0>
X-Attachment-Id: f_juyj59yr0

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvZnRyYWNlLmMgYi9hcmNoL2lhNjQva2VybmVs
L2Z0cmFjZS5jCmluZGV4IDdmYzhjOTYxYjFmNy4uOTgwODVkY2JmMjBhIDEwMDY0NAotLS0gYS9h
cmNoL2lhNjQva2VybmVsL2Z0cmFjZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvZnRyYWNlLmMK
QEAgLTExNCw3ICsxMTQsOCBAQCBmdHJhY2VfbW9kaWZ5X2NvZGUodW5zaWduZWQgbG9uZyBpcCwg
dW5zaWduZWQgY2hhciAqb2xkX2NvZGUsCiAJCXJldHVybiAtRUZBVUxUOwogCiAJLyogTWFrZSBz
dXJlIGl0IGlzIHdoYXQgd2UgZXhwZWN0IGl0IHRvIGJlICovCi0JaWYgKG1lbWNtcChyZXBsYWNl
ZCwgb2xkX2NvZGUsIE1DT1VOVF9JTlNOX1NJWkUpICE9IDApCisJaWYgKG9sZF9jb2RlICE9IE5V
TEwgJiYKKwkgICAgbWVtY21wKHJlcGxhY2VkLCBvbGRfY29kZSwgTUNPVU5UX0lOU05fU0laRSkg
IT0gMCkKIAkJcmV0dXJuIC1FSU5WQUw7CiAKIHNraXBfY2hlY2s6Cg==
--000000000000c7c79f0587751a3c--
