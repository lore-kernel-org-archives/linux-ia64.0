From: Sven Schnelle <svens@linux.ibm.com>
Date: Tue, 05 Jul 2022 17:28:49 +0000
Subject: Re: [PATCH v4 12/12] sched,signal,ptrace: Rework TASK_TRACED, TASK_STOPPED state
Message-Id: <yt9dpmijcvu6.fsf@linux.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
List-Id: <linux-ia64.vger.kernel.org>
References: <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220505182645.497868-12-ebiederm@xmission.com>
        <YrHA5UkJLornOdCz@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
        <877d5ajesi.fsf@email.froward.int.ebiederm.org>
        <YrHgo8GKFPWwoBoJ@li-4a3a4a4c-28e5-11b2-a85c-a8d192c6f089.ibm.com>
        <20220628191541.34a073fc@gandalf.local.home>
        <yt9d5ykbekn3.fsf@linux.ibm.com>
In-Reply-To: <yt9d5ykbekn3.fsf@linux.ibm.com> (Sven Schnelle's message of
        "Tue, 05 Jul 2022 15:47:44 +0200")
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Alexander Gordeev <agordeev@linux.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: 

Sven Schnelle <svens@linux.ibm.com> writes:

> Steven Rostedt <rostedt@goodmis.org> writes:
>
>> On Tue, 21 Jun 2022 17:15:47 +0200
>> Alexander Gordeev <agordeev@linux.ibm.com> wrote:
>>
>>> So I assume (checked actually) the return 0 below from kernel/sched/core.c:
>>> wait_task_inactive() is where it bails out:
>>> 
>>> 3303                 while (task_running(rq, p)) {
>>> 3304                         if (match_state && unlikely(READ_ONCE(p->__state) != match_state))
>>> 3305                                 return 0;
>>> 3306                         cpu_relax();
>>> 3307                 }
>>> 
>>> Yet, the child task is always found in __TASK_TRACED state (as seen
>>> in crash dumps):
>>> 
>>> > 101447  11342  13      ce3a8100      RU   0.0   10040   4412  strace  
>>>   101450  101447   0      bb04b200      TR   0.0    2272   1136  kill_child
>>>   108261  101447   2      d0b10100      TR   0.0    2272    532  kill_child
>>> crash> task bb04b200 __state  
>>> PID: 101450  TASK: bb04b200          CPU: 0   COMMAND: "kill_child"
>>>   __state = 8,
>>> 
>>> crash> task d0b10100 __state  
>>> PID: 108261  TASK: d0b10100          CPU: 2   COMMAND: "kill_child"
>>>   __state = 8,
>>
>> If you are using crash, can you enable all trace events?
>>
>> Then you should be able to extract the ftrace ring buffer from crash using
>> the trace.so extend (https://github.com/fujitsu/crash-trace)
>>
>> I guess it should still work with s390.
>>
>> Then you can see the events that lead up to the crash.

I think there's a race in ptrace_check_attach(). It first calls
ptrace_freeze_task(), which checks whether JOBCTL_TRACED is set.
If it is (and a few other conditions match) it will set ret = 0.

Later outside of siglock and tasklist_lock it will call
wait_task_inactive, assuming the target is in TASK_TRACED, but it isn't.

ptrace_stop(), which runs on another CPU, does:

set_special_state(TASK_TRACED);
current->jobctl |= JOBCTL_TRACED;

which looks ok on first sight, but in this case JOBCTL is already set,
so the reading CPU will immediately move on to wait_task_inactive(),
before JOBCTL_TRACED is set. I don't know whether this is a valid
combination. I never looked into JOBCTL_* semantics, but i guess now
is a good time to do so. I added some debugging statements, and that
gives:

[   86.218488] kill_chi-300545    2d.... 79990135us : ptrace_stop: state 8
[   86.218492] kill_chi-300545    2d.... 79990136us : signal_generate: sig=17 errno=0 code=4 comm=strace pid=300542 grp=1 res=1
[   86.218496] kill_chi-300545    2d.... 79990136us : sched_stat_runtime: comm=kill_child pid=300545 runtime=3058 [ns] vruntime=606165713178 [ns]
[   86.218500] kill_chi-300545    2d.... 79990136us : sched_switch: prev_comm=kill_child prev_pid=300545 prev_prio=120 prev_state=t ==> next_comm=swapper/2 next_pid=0 next_prio=120
[   86.218504]   strace-300542    7..... 79990139us : sys_ptrace -> 0x50
[   86.218508]   strace-300542    7..... 79990139us : sys_write(fd: 2, buf: 2aa198f7ad0, count: 12)
[   86.218512]   strace-300542    7..... 79990140us : sys_write -> 0x12
[   86.218515]   <idle>-0         6dNh.. 79990140us : sched_wakeup: comm=kill_child pid=343805 prio=120 target_cpu=006
[   86.218519]   <idle>-0         6d.... 79990140us : sched_switch: prev_comm=swapper/6 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=kill_child next_pid=343805 next_prio=120
[   86.218524]   strace-300542    7..... 79990140us : sys_write(fd: 2, buf: 2aa198f7ad0, count: 19)
[   86.218527]   strace-300542    7..... 79990141us : sys_write -> 0x19
[   86.218531] kill_chi-343805    6..... 79990141us : sys_sched_yield -> 0xffffffffffffffda
[   86.218535]   strace-300542    7..... 79990141us : sys_ptrace(request: 18, pid: 53efd, addr: 0, data: 0)
[   86.218539] kill_chi-343805    6d.... 79990141us : signal_deliver: sig=9 errno=0 code=0 sa_handler=0 sa_flags=0
[   86.218543]   strace-300542    7d.... 79990141us : ptrace_check_attach: task_is_traced: 1, fatal signal pending: 0
[   86.218547]   strace-300542    7..... 79990141us : ptrace_check_attach: child->pid = 343805, child->__flags=0
[   86.218551] kill_chi-343805    6d.... 79990141us : ptrace_stop: JOBCTL_TRACED already set, state=0 <------ valid combination of flags?
[   86.218554] kill_chi-343805    6d.... 79990141us : ptrace_stop: state 8
[   86.218558] kill_chi-343805    6d.... 79990142us : signal_generate: sig=17 errno=0 code=4 comm=strace pid=300542 grp=1 res=1
[   86.218562] kill_chi-343805    6d.... 79990142us : sched_stat_runtime: comm=kill_child pid=343805 runtime=2135 [ns] vruntime=556109013931 [ns]
[   86.218566]   strace-300542    7..... 79990142us : wait_task_inactive: NO MATCH: state 0, match_state 8, pid 343805
[   86.218570] kill_chi-343805    6d.... 79990142us : sched_switch: prev_comm=kill_child prev_pid=343805 prev_prio=120 prev_state=t ==>next_comm=swapper/6 next_pid=0 next_prio=120


--=-=-=
Content-Type: text/x-diff
Content-Disposition: inline; filename=ptrace-debug.patch

diff --git a/include/linux/sched.h b/include/linux/sched.h
index c46f3a63b758..c2ddc47271b8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -154,8 +154,8 @@ struct task_group;
 	} while (0)
 
 #else
-# define debug_normal_state_change(cond)	do { } while (0)
-# define debug_special_state_change(cond)	do { } while (0)
+# define debug_normal_state_change(cond)	do { trace_printk("state %d\n", cond); } while (0)
+# define debug_special_state_change(cond)	do { trace_printk("state %d\n", cond); } while (0)
 # define debug_rtlock_wait_set_state()		do { } while (0)
 # define debug_rtlock_wait_restore_state()	do { } while (0)
 #endif
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 156a99283b11..2cb2ae8acf23 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -202,6 +202,7 @@ static bool ptrace_freeze_traced(struct task_struct *task)
 	spin_lock_irq(&task->sighand->siglock);
 	if (task_is_traced(task) && !looks_like_a_spurious_pid(task) &&
 	    !__fatal_signal_pending(task)) {
+		trace_printk("task_is_traced: %d, fatal signal pending: %d\n", task_is_traced(task), __fatal_signal_pending(task));
 		task->jobctl |= JOBCTL_PTRACE_FROZEN;
 		ret = true;
 	}
@@ -263,8 +264,10 @@ static int ptrace_check_attach(struct task_struct *child, bool ignore_state)
 		 * child->sighand can't be NULL, release_task()
 		 * does ptrace_unlink() before __exit_signal().
 		 */
-		if (ignore_state || ptrace_freeze_traced(child))
+		if (ignore_state || ptrace_freeze_traced(child)) {
+			trace_printk("child->pid = %d, child->__flags=%d\n", child->pid, child->__state);
 			ret = 0;
+		}
 	}
 	read_unlock(&tasklist_lock);
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index da0bf6fe9ecd..73bb4c7882d0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3301,8 +3301,10 @@ unsigned long wait_task_inactive(struct task_struct *p, unsigned int match_state
 		 * is actually now running somewhere else!
 		 */
 		while (task_running(rq, p)) {
-			if (match_state && unlikely(READ_ONCE(p->__state) != match_state))
+			if (match_state && unlikely(READ_ONCE(p->__state) != match_state)) {
+				trace_printk("NO MATCH: state %d, match_state %d, pid %d\n", p->__state, match_state, p->pid);
 				return 0;
+			}
 			cpu_relax();
 		}
 
diff --git a/kernel/signal.c b/kernel/signal.c
index edb1dc9b00dc..0ea8e6b6a641 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2232,6 +2232,8 @@ static int ptrace_stop(int exit_code, int why, unsigned long message,
 	if (!current->ptrace || __fatal_signal_pending(current))
 		return exit_code;
 
+	if (current->jobctl & JOBCTL_TRACED)
+		trace_printk("JOBCTL_TRACED already set, state=%d\n", current->__state);
 	set_special_state(TASK_TRACED);
 	current->jobctl |= JOBCTL_TRACED;
 

--=-=-=
Content-Type: text/plain


I'll continue debugging tomorrow, but maybe this helps already.

--=-=-=--
