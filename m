From: Adam Richter <adamrichter4@gmail.com>
Date: Sun, 28 Apr 2019 22:21:00 +0000
Subject: [Untested patch] ia64: Eliminate goto from ftrace_modify_code
Message-Id: <CAGn-TghMGi-wqWF-v9qRkZHtqh01byXXOQKfVWgAvNxm5hxMoQ@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="000000000000cfdd9605879e95cc"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--000000000000cfdd9605879e95cc
Content-Type: text/plain; charset="UTF-8"

The attached untested patch avoids a cppcheck warning by eliminating
an unnecessary use of goto, which apparently caused cppcheck not to
recognize the impossibility of a null pointer dereference in one case.
It as a revision to my previous incorrect patch from two days ago
("Suspected null pointer dereference in ftrace_make_nop() for ia64").

Ideally, cppcheck should be enhanced to recognize "goto" usage in this
form and do the same analysis that it does with "if" statements (and I
intend to look into that), but, even with such a cppcheck enhancement,
I believe it still helps maintainability to avoid using "goto"
statements that do not provide some technical benefit.

I have not built or tested this change, and I am aware that yesterday
Greg K-H asked everyone to avoid device driver churn for untested
code.  So, I am not requesting integration without someone else trying
it first.  I am, however, posting this patch just in case anyone to
try it at some point and then submit it upstream if it actually works
and their are no complaints.

I hereby release my copyright interest in this contribution to the
public domain.  Please let me know if anyone needs me to make any
other statements with regard to this patch.

Adam

--000000000000cfdd9605879e95cc
Content-Type: text/x-diff; charset="US-ASCII"; 
	name="ia64_ftrace_modify_code.remove_goto.diff"
Content-Disposition: attachment; 
	filename="ia64_ftrace_modify_code.remove_goto.diff"
Content-Transfer-Encoding: base64
Content-ID: <f_jv1hdt5t0>
X-Attachment-Id: f_jv1hdt5t0

ZGlmZiAtLWdpdCBhL2FyY2gvaWE2NC9rZXJuZWwvZnRyYWNlLmMgYi9hcmNoL2lhNjQva2VybmVs
L2Z0cmFjZS5jCmluZGV4IDdmYzhjOTYxYjFmNy4uNzg4ZjcwZWY1MzQ2IDEwMDY0NAotLS0gYS9h
cmNoL2lhNjQva2VybmVsL2Z0cmFjZS5jCisrKyBiL2FyY2gvaWE2NC9rZXJuZWwvZnRyYWNlLmMK
QEAgLTEwNiwxOCArMTA2LDE3IEBAIGZ0cmFjZV9tb2RpZnlfY29kZSh1bnNpZ25lZCBsb25nIGlw
LCB1bnNpZ25lZCBjaGFyICpvbGRfY29kZSwKIAkgKiBrc3RvcF9tYWNoaW5lLCBvciBiZWZvcmUg
U01QIHN0YXJ0cy4KIAkgKi8KIAotCWlmICghZG9fY2hlY2spCi0JCWdvdG8gc2tpcF9jaGVjazsK
KwlpZiAoZG9fY2hlY2spIHsKIAotCS8qIHJlYWQgdGhlIHRleHQgd2Ugd2FudCB0byBtb2RpZnkg
Ki8KLQlpZiAocHJvYmVfa2VybmVsX3JlYWQocmVwbGFjZWQsICh2b2lkICopaXAsIE1DT1VOVF9J
TlNOX1NJWkUpKQotCQlyZXR1cm4gLUVGQVVMVDsKKwkJLyogcmVhZCB0aGUgdGV4dCB3ZSB3YW50
IHRvIG1vZGlmeSAqLworCQlpZiAocHJvYmVfa2VybmVsX3JlYWQocmVwbGFjZWQsICh2b2lkICop
aXAsIE1DT1VOVF9JTlNOX1NJWkUpKQorCQkJcmV0dXJuIC1FRkFVTFQ7CiAKLQkvKiBNYWtlIHN1
cmUgaXQgaXMgd2hhdCB3ZSBleHBlY3QgaXQgdG8gYmUgKi8KLQlpZiAobWVtY21wKHJlcGxhY2Vk
LCBvbGRfY29kZSwgTUNPVU5UX0lOU05fU0laRSkgIT0gMCkKLQkJcmV0dXJuIC1FSU5WQUw7CisJ
CS8qIE1ha2Ugc3VyZSBpdCBpcyB3aGF0IHdlIGV4cGVjdCBpdCB0byBiZSAqLworCQlpZiAobWVt
Y21wKHJlcGxhY2VkLCBvbGRfY29kZSwgTUNPVU5UX0lOU05fU0laRSkgIT0gMCkKKwkJCXJldHVy
biAtRUlOVkFMOworCX0KIAotc2tpcF9jaGVjazoKIAkvKiByZXBsYWNlIHRoZSB0ZXh0IHdpdGgg
dGhlIG5ldyB0ZXh0ICovCiAJaWYgKHByb2JlX2tlcm5lbF93cml0ZSgoKHZvaWQgKilpcCksIG5l
d19jb2RlLCBNQ09VTlRfSU5TTl9TSVpFKSkKIAkJcmV0dXJuIC1FUEVSTTsK
--000000000000cfdd9605879e95cc--
