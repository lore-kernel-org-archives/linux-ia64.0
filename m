From: Kees Cook <keescook@chromium.org>
Date: Fri, 06 May 2022 21:26:36 +0000
Subject: Re: [PATCH v4 0/12] ptrace: cleaning up ptrace_stop
Message-Id: <202205061348.927E94729E@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
 <20220421150654.817117821@infradead.org>
 <87czhap9dy.fsf@email.froward.int.ebiederm.org>
 <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
 <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
 <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
In-Reply-To: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org, Robert O'Callahan <roc@pernos.co>, Kyle Huey <khuey@pernos.co>

On Thu, May 05, 2022 at 01:25:57PM -0500, Eric W. Biederman wrote:
> The states TASK_STOPPED and TASK_TRACE are special in they can not
> handle spurious wake-ups.  This plus actively depending upon and
> changing the value of tsk->__state causes problems for PREEMPT_RT and
> Peter's freezer rewrite.
> 
> There are a lot of details we have to get right to sort out the
> technical challenges and this is my parred back version of the changes
> that contains just those problems I see good solutions to that I believe
> are ready.
> 
> A couple of issues have been pointed but I think this parred back set of
> changes is still on the right track.  The biggest change in v4 is the
> split of "ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs" into
> two patches because the dependency I thought exited between two
> different changes did not exist.  The rest of the changes are minor
> tweaks to "ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs";
> removing an always true branch, and adding an early  test to see if the
> ptracer had gone, before TASK_TRAPPING was set.
> 
> This set of changes should support Peter's freezer rewrite, and with the
> addition of changing wait_task_inactive(TASK_TRACED) to be
> wait_task_inactive(0) in ptrace_check_attach I don't think there are any
> races or issues to be concerned about from the ptrace side.
> 
> More work is needed to support PREEMPT_RT, but these changes get things
> closer.
> 
> This set of changes continues to look like it will provide a firm
> foundation for solving the PREEMPT_RT and freezer challenges.

One of the more sensitive projects to changes around ptrace is rr
(Robert and Kyle added to CC). I ran rr's selftests before/after this
series and saw no changes. My failures remained the same; I assume
they're due to missing CPU features (pkeys) or build configs (bpf), etc:

99% tests passed, 19 tests failed out of 2777

Total Test time (real) = 773.40 sec

The following tests FAILED:
         42 - bpf_map (Failed)
         43 - bpf_map-no-syscallbuf (Failed)
        414 - netfilter (Failed)
        415 - netfilter-no-syscallbuf (Failed)
        454 - x86/pkeys (Failed)
        455 - x86/pkeys-no-syscallbuf (Failed)
        1152 - ttyname (Failed)
        1153 - ttyname-no-syscallbuf (Failed)
        1430 - bpf_map-32 (Failed)
        1431 - bpf_map-32-no-syscallbuf (Failed)
        1502 - detach_sigkill-32 (Failed)
        1802 - netfilter-32 (Failed)
        1803 - netfilter-32-no-syscallbuf (Failed)
        1842 - x86/pkeys-32 (Failed)
        1843 - x86/pkeys-32-no-syscallbuf (Failed)
        2316 - crash_in_function-32 (Failed)
        2317 - crash_in_function-32-no-syscallbuf (Failed)
        2540 - ttyname-32 (Failed)
        2541 - ttyname-32-no-syscallbuf (Failed)

So, I guess:

Tested-by: Kees Cook <keescook@chromium.org>

:)

-- 
Kees Cook
