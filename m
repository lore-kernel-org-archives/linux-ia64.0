From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 09:07:42 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <20050729090742.GA8438@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <42E9ED47.1030003@yahoo.com.au>
In-Reply-To: <42E9ED47.1030003@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Well, you can easily see suboptimal scheduling decisions on many 
> programs with lots of interprocess communication. For example, tbench 
> on a dual Xeon:
> 
> processes    1               2               3              4
> 
> 2.6.13-rc4:  187, 183, 179   260, 259, 256   340, 320, 349  504, 496, 500
> no wake-bal: 180, 180, 177   254, 254, 253   268, 270, 348  345, 290, 500
> 
> Numbers are MB/s, higher is better.

i cannot see any difference with/without wake-balancing in this 
workload, on a dual Xeon. Could you try the quick hack below and do:

	echo 1 > /proc/sys/kernel/panic # turn on wake-balancing
	echo 0 > /proc/sys/kernel/panic # turn off wake-balancing

does the runtime switching show any effects on the throughput numbers 
tbench is showing? I'm using dbench-3.03. (i only checked the status 
numbers, didnt do full runs)

(did you have SCHED_SMT enabled?)

	Ingo

 kernel/sched.c |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-prefetch-task/kernel/sched.c
=================================--- linux-prefetch-task.orig/kernel/sched.c
+++ linux-prefetch-task/kernel/sched.c
@@ -1155,6 +1155,8 @@ static int try_to_wake_up(task_t * p, un
 		goto out_activate;
 
 	new_cpu = cpu;
+	if (!panic_timeout)
+		goto out_set_cpu;
 
 	schedstat_inc(rq, ttwu_cnt);
 	if (cpu = this_cpu) {
