From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:31:50 +0000
Subject: [PATCH 0/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BD46.7060700@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, ia64 folks.

Here is a set of patch to implement VIRT_CPU_ACCOUNTING for ia64,
which enable us to use more accurate cpu time accounting.

-----
[1/9] ia64_add_config_virt_cpu_accounting.patch
[2/9] ia64_expand_ia64_cputime_h.patch
[3/9] ia64_cputime_to_nsec.patch
[4/9] ia64_self_update_process_times.patch
[5/9] ia64_acct_vars.patch
[6/9] ia64_acct_gate_on_switch.patch
[7/9] ia64_acct_gate_on_entry.patch
[8/9] ia64_acct_gate_on_leave.patch
[9/9] ia64_acct_get_vtime.patch
-----

The cpu time accounting is a mechanism to determine how long
the cpus are used for particular purpose, and also how long a
thread uses cpu - values indicated in stime or utime.

Now the cpu time accounting on ia64 system (and many other archs)
is based on sampling at the time of tick(timer interrupt).
If a thread is running in kernel mode at an timer interrupt, then
the accounting increments the stime of the thread considering that
the thread have consume cpu time in kernel mode from last tick to
present. If the thread was swapper, then the accounting consider
the cpu was idle from last tick.

This assumption that thread did not change from last tick is not
always true, mostly false in modern hi-speed machines.
If the stime of a thread has value 100, people tend to imagine that
"this thread ran 100/HZ sec in kernel mode", however, the true
meaning of the value is "this thread interrupted by tick 100 times
while it is running in kernel mode" in fact, and thats all.

ex.)
+----+----+----+----+----+----+-> time (+ = tick)
........SSUUUSSSUUSSUSS........ thread1 ([stime,utime] = [1,2])
.SSUUUUSSS.SSUUSUSS...SSUUUSSS. thread2 ([stime,utime] = [1,2])
........SUS...SUS..SUS......... thread3 ([stime,utime] = [1,2])
(Note that all of these 3 threads really uses cpu time more in
 system, not in user.)

Therefore, more accurate cpu time accounting is required to know
how long the thread actually uses cpus, what purpose takes time
of particular cpu, and so on.

The VIRT_CPU_ACCOUNTING is an item of kernel config, which s390
and powerpc arch have.  By turning this config on, these archs
change the mechanism of cpu time accounting from tick-sampling
based one to state-transition based one.

The state-transition based accounting is done by checking time
(cycle counter in processor) at every state-transition point,
such as entrance/exit of kernel, interrupt, softirq etc.
The difference between point to point is the actual time consumed
during in the state. There is no doubt about that this value is
more accurate than that of tick-based accounting.

My patches here port this VIRT_CPU_ACCOUNTING from these IBM archs.
Some performance impact is expected, but as far as my brief tests,
it looks like nothing much to worry about.

I'd appreciate it if you could try this option and send me your
feedback. Especially idea for optimization would be welcomed.

Thanks,
H.Seto


