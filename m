From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 09 Oct 2003 15:36:51 +0000
Subject: wrong initial ia64_kr(current_stack) value
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C38E7B.29196AC4"
Message-Id: <marc-linux-ia64-106571413927132@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C38E7B.29196AC4
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We start seeing random kernel hang at fairly late stage of booting when =
lots of processes are spawned by the init script.  The kernel used is a =
variant of 2.4.21.  At the time of the hang, one CPU is stuck in page =
fault handler with no apparent valid dtlb mapping for the kernel stack.  =
Interesting enough, the task that the stuck CPU is executing has its =
kernel stack allocated out of 16-32MB physical memory range (we are =
using 16MB kernel granule in this exercise).  We finally tracked it down =
to be a bug in _start() where IA64_KR(CURRENT_STACK) was incorrectly =
initialized.

This code in head.S is wrong:
=20
    mov r16=3DKERNEL_TR_PAGE_NUM
    ;;

    // load the "current" pointer (r13) and ar.k6 with the current task
    mov r13=3Dr2
    mov IA64_KR(CURRENT)=3Dr3         // Physical address

    // initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
    mov IA64_KR(CURRENT_STACK)=3Dr16


r16 is loaded with the kernel page number measured in =
(1<<KERNEL_TR_PAGE_SHIFT) pages, but the check in ia64_switch_to() =
expects it to be in (1<<IA64_GRANULE_SHIFT) units.  When granule size is =
16MB, we can hit a problem if the task structure area (the 2 pages =
allocated for task_stuct and kernel stack area) of the first process =
that we switch out of idle is in the physical address range [16MB,32MB], =
as the check in ia64_switch_to() will mistakenly think that we already =
have this mapping loaded in dtr[2] but actually it doesn't.

The hang will end up with nested TLB fault where secondary DTLB miss for =
the kernel stack will never complete.  The mishap is due to =
initialization code using the wrong page size when computing the initial =
value for the "safe" page number that was stored in a kernel register =
marking which address was mapped for the stack.  ia64_switch_to is =
really confused on which page is mapped in DTR when coming out of idle, =
because someone lied to him.

I'm surprised that this bug has gone underground for so long.  It could =
happen on any SMP system out there, but it is easier for the bug to bite =
on a system with lots of CPUs.  Here is a patch that fixed problem.  =
Kudos to Tony Luck, Kimi Suganuma and Nomura-san for helping me track =
this down.

- Ken

p.s. only 2.4.x kernel has this bug.


------_=_NextPart_001_01C38E7B.29196AC4
Content-Type: application/octet-stream;
	name="stack_tr.patch"
Content-Transfer-Encoding: base64
Content-Description: stack_tr.patch
Content-Disposition: attachment;
	filename="stack_tr.patch"

PT09PT0gYXJjaC9pYTY0L2tlcm5lbC9oZWFkLlMgMS4xIHZzIGVkaXRlZCA9PT09PQotLS0gMS4x
L2FyY2gvaWE2NC9rZXJuZWwvaGVhZC5TCUZyaSBPY3QgIDMgMjM6MDA6MTUgMjAwMworKysgZWRp
dGVkL2FyY2gvaWE2NC9rZXJuZWwvaGVhZC5TCVdlZCBPY3QgIDggMTM6Mzc6NDUgMjAwMwpAQCAt
MTQ3LDcgKzE0Nyw3IEBACiAJY21wNC5uZSBpc0FQLGlzQlA9cjMscjAKIAk7OwkJCS8vIFJBVyBv
biByMgogCWV4dHIgcjM9cjIsMCw2MQkJLy8gcjMgPT0gcGh5cyBhZGRyIG9mIHRhc2sgc3RydWN0
Ci0JbW92IHIxNj1LRVJORUxfVFJfUEFHRV9OVU0KKwltb3YgcjE2PShLRVJORUxfU1RBUlQgLSBQ
QUdFX09GRlNFVCkgLyBJQTY0X0dSQU5VTEVfU0laRQogCTs7CiAKIAkvLyBsb2FkIHRoZSAiY3Vy
cmVudCIgcG9pbnRlciAocjEzKSBhbmQgYXIuazYgd2l0aCB0aGUgY3VycmVudCB0YXNrCg==

------_=_NextPart_001_01C38E7B.29196AC4--
