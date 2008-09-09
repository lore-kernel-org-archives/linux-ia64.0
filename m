From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 09 Sep 2008 03:06:27 +0000
Subject: Re: [RFC PATCH] set TASK_TRACED before arch_ptrace code to fix a race
Message-Id: <3877989d0809082006v496bae4i1c0736f5d55e9b9f@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_79012_29379045.1220929587360"
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0805211947i54bacc7cv619541e9b40824fb@mail.gmail.com>
	 <1211869515.29836.2.camel@elijah.suse.cz>
	 <3877989d0806022304w35764b17p9d4c3c95eceae0f5@mail.gmail.com>
	 <48450864.6080707@suse.cz> <48455619.6040608@suse.cz>
	 <3877989d0806031916wf11bb2t3847aa630fb39e60@mail.gmail.com>
	 <48465D5C.8000804@suse.cz>
	 <3877989d0806041849vb903aaw221de929e2ab8cb9@mail.gmail.com>
	 <1212664605.15747.16.camel@elijah.suse.cz>
	 <20080627204954.34F8B154231@magilla.localdomain>
In-Reply-To: <20080627204954.34F8B154231@magilla.localdomain>
To: Roland McGrath <roland@redhat.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

------=_Part_79012_29379045.1220929587360
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Just have chance to re-check the problem. I have spotted the place that strace
misbehaves when SIGTRAP is blocked by task being straced with -f flag
(follow trace)
The problem is that after debugee blocking SIGTRAP the task's exec
path would not wake up debugger (strace) with this signal. But strace
don't know about it, and expect such a wake up. Upon receiving a
subsequent wake up,strace still thought it was a wake up from "SIGTRAP
in previous exec path". From now on, Debuger and Debugee misunderstand
each other..

With the test case posted before in this thread and a customized
kernel, I got the following debug info from kernel:

syscall_trace_enter exiting (4717)
report_exec:pid= 4717 parent=4715, real_parent=4716,current->ptrace =00000001,
report_exec:pid= 4717 parent=4715, real_parent=4716,current->ptrace =00000001,
syscall_trace_leave entering (4717, syscall:1033)
 ..sig_ignored=1..
4715, PTRACE_PEEKUSR 4717 @addr 00000830 return 00000000
4715, PTRACE_PEEKUSR 4717 @addr 000008c0 return 00000000
4715, PTRACE_PEEKUSR 4717 @addr 000008d0 return 00000000
4715, PTRACE_PEEKUSR 4717 @addr 000008d0 return 00000000
4715, PTRACE_PEEKUSR 4717 @addr 000008c0 return 00000000
syscall_trace current(4717)->exit_code(0)
syscall_trace_leave exiting (4717)
syscall_trace_enter beginning (4717, syscall: 1060)
 ..sig_ignored=1..
4715, PTRACE_PEEKUSR 4717 @addr 00000830 return 00000010
4715, PTRACE_PEEKUSR 4717 @addr 000008b8 return 00000424
syscall_trace current(4717)->exit_code(0)
syscall_trace_enter exiting (4717)

Delete the line that blocks SIGTRAP in the test case, rerun it, I got:

syscall_trace current(4724)->exit_code(0)
syscall_trace_enter exiting (4724)
report_exec:pid= 4724 parent=4722, real_parent=4723,current->ptrace =00000001,
report_exec:pid= 4724 parent=4722, real_parent=4723,current->ptrace =00000001,
syscall_trace_leave entering (4724, syscall:1033)
 ..sig_ignored=1..
4722, PTRACE_PEEKUSR 4724 @addr 00000830 return 00000000
4722, PTRACE_PEEKUSR 4724 @addr 000008c0 return 00000000
4722, PTRACE_PEEKUSR 4724 @addr 000008d0 return 00000000
4722, PTRACE_PEEKUSR 4724 @addr 000008d0 return 00000000
4722, PTRACE_PEEKUSR 4724 @addr 000008c0 return 00000000
syscall_trace current(4724)->exit_code(0)
syscall_trace_leave exiting (4724)
 ..sig_ignored=1..
4722, PTRACE_PEEKUSR 4724 @addr 00000830 return 00000000
4722, PTRACE_PEEKUSR 4724 @addr 000008b8 return 00000409
syscall_trace_enter beginning (4724, syscall: 1060)
 ..sig_ignored=1..


The attahced patch is a proposal for this problem. But I still don't know
why it is just specific to IA64.

***Note: The following patch is copy&paste, If you want apply, please
check out the attached version


Signed-off-by: Yu Luming <luming.yu@intel.com>
--------------------------------------
 include/linux/tracehook.h |    4 +++-
 kernel/signal.c           |   11 ++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff -Bru 0/include/linux/tracehook.h 1/include/linux/tracehook.h
--- 0/include/linux/tracehook.h 2008-08-18 20:43:21.000000000 -0400
+++ 1/include/linux/tracehook.h 2008-09-09 09:51:14.000000000 -0400
@@ -195,8 +195,10 @@
                                         struct pt_regs *regs)
 {
        if (!ptrace_event(PT_TRACE_EXEC, PTRACE_EVENT_EXEC, 0) &&
-           unlikely(task_ptrace(current) & PT_PTRACED))
+           unlikely(task_ptrace(current) & PT_PTRACED)){
                send_sig(SIGTRAP, current, 0);
+               set_tsk_thread_flag(current,TIF_SIGPENDING);
+       }
 }

 /**
diff -Bru 0/kernel/signal.c 1/kernel/signal.c
--- 0/kernel/signal.c   2008-08-18 20:43:21.000000000 -0400
+++ 1/kernel/signal.c   2008-09-09 09:50:38.000000000 -0400
@@ -384,8 +384,14 @@
 static int __dequeue_signal(struct sigpending *pending, sigset_t *mask,
                        siginfo_t *info)
 {
-       int sig = next_signal(pending, mask);
+       int sig = 0;
+       int allow_trap = 0;

+       if((current->ptrace & PT_PTRACED) && sigismember(mask,SIGTRAP)){
+               sigdelset(mask,SIGTRAP);
+               allow_trap = 1;
+       }
+       sig = next_signal(pending, mask);
        if (sig) {
                if (current->notifier) {
                        if (sigismember(current->notifier_mask, sig)) {
@@ -399,6 +405,9 @@
                collect_signal(sig, pending, info);
        }

+       if(allow_trap)
+               sigaddset(mask,SIGTRAP);
+
        return sig;
}

On Fri, Jun 6, 2008 at 8:07 AM, Roland McGrath <roland@redhat.com> wrote:
>> I _guess_ this is caused by the fact that test2.sh is a shell script, so
>> the kernel executes the shell, and maybe utrace produces a second execve
>> notifications in this case? Roland, can you shed some light?
>
> Not really.  The utrace kernels Luming is trying are intended to match the
> vanilla ptrace behavior.  I don't think it's very useful to worry about the
> difference between some utrace kernel and the current vanilla kernel.
> Let's just look at what the current vanilla kernel is doing and compare
> that to what an older vanilla kernel did if older versions produced
> different results for the test case.
>
>
> Thanks,
> Roland
>

------=_Part_79012_29379045.1220929587360
Content-Type: application/octet-stream; name=44620-upstream.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fkvxvebt0
Content-Disposition: attachment; filename=44620-upstream.patch

ZGlmZiAtQnJ1IDAvaW5jbHVkZS9saW51eC90cmFjZWhvb2suaCAxL2luY2x1ZGUvbGludXgvdHJh
Y2Vob29rLmgKLS0tIDAvaW5jbHVkZS9saW51eC90cmFjZWhvb2suaAkyMDA4LTA4LTE4IDIwOjQz
OjIxLjAwMDAwMDAwMCAtMDQwMAorKysgMS9pbmNsdWRlL2xpbnV4L3RyYWNlaG9vay5oCTIwMDgt
MDktMDkgMDk6NTE6MTQuMDAwMDAwMDAwIC0wNDAwCkBAIC0xOTUsOCArMTk1LDEwIEBACiAJCQkJ
CSBzdHJ1Y3QgcHRfcmVncyAqcmVncykKIHsKIAlpZiAoIXB0cmFjZV9ldmVudChQVF9UUkFDRV9F
WEVDLCBQVFJBQ0VfRVZFTlRfRVhFQywgMCkgJiYKLQkgICAgdW5saWtlbHkodGFza19wdHJhY2Uo
Y3VycmVudCkgJiBQVF9QVFJBQ0VEKSkKKwkgICAgdW5saWtlbHkodGFza19wdHJhY2UoY3VycmVu
dCkgJiBQVF9QVFJBQ0VEKSl7CiAJCXNlbmRfc2lnKFNJR1RSQVAsIGN1cnJlbnQsIDApOworCQlz
ZXRfdHNrX3RocmVhZF9mbGFnKGN1cnJlbnQsVElGX1NJR1BFTkRJTkcpOworCX0KIH0KIAogLyoq
CmRpZmYgLUJydSAwL2tlcm5lbC9zaWduYWwuYyAxL2tlcm5lbC9zaWduYWwuYwotLS0gMC9rZXJu
ZWwvc2lnbmFsLmMJMjAwOC0wOC0xOCAyMDo0MzoyMS4wMDAwMDAwMDAgLTA0MDAKKysrIDEva2Vy
bmVsL3NpZ25hbC5jCTIwMDgtMDktMDkgMDk6NTA6MzguMDAwMDAwMDAwIC0wNDAwCkBAIC0zODQs
OCArMzg0LDE0IEBACiBzdGF0aWMgaW50IF9fZGVxdWV1ZV9zaWduYWwoc3RydWN0IHNpZ3BlbmRp
bmcgKnBlbmRpbmcsIHNpZ3NldF90ICptYXNrLAogCQkJc2lnaW5mb190ICppbmZvKQogewotCWlu
dCBzaWcgPSBuZXh0X3NpZ25hbChwZW5kaW5nLCBtYXNrKTsKKwlpbnQgc2lnID0gMDsKKwlpbnQg
YWxsb3dfdHJhcCA9IDA7CiAKKwlpZigoY3VycmVudC0+cHRyYWNlICYgUFRfUFRSQUNFRCkgJiYg
c2lnaXNtZW1iZXIobWFzayxTSUdUUkFQKSl7CisJCXNpZ2RlbHNldChtYXNrLFNJR1RSQVApOwor
CQlhbGxvd190cmFwID0gMTsKKwl9CisJc2lnID0gbmV4dF9zaWduYWwocGVuZGluZywgbWFzayk7
CiAJaWYgKHNpZykgewogCQlpZiAoY3VycmVudC0+bm90aWZpZXIpIHsKIAkJCWlmIChzaWdpc21l
bWJlcihjdXJyZW50LT5ub3RpZmllcl9tYXNrLCBzaWcpKSB7CkBAIC0zOTksNiArNDA1LDkgQEAK
IAkJY29sbGVjdF9zaWduYWwoc2lnLCBwZW5kaW5nLCBpbmZvKTsKIAl9CiAKKwlpZihhbGxvd190
cmFwKQorCQlzaWdhZGRzZXQobWFzayxTSUdUUkFQKTsKKwogCXJldHVybiBzaWc7CiB9CiAK
------=_Part_79012_29379045.1220929587360--
