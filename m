From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Jan 2005 17:41:16 +0000
Subject: pipe performance regression on ia64
Message-Id: <200501181741.j0IHfGf30058@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@osdl.org
Cc: linux-ia64@vger.kernel.org

David Mosberger pointed out to me that 2.6.11-rc1 kernel scores
very badly on ia64 in lmbench pipe throughput test (bw_pipe) compared
with earlier kernels.

Nanhai Zou looked into this, and found that the performance loss
began with Linus' patch to speed up pipe performance by allocating
a circular list of pages.

Here's his analysis:

>OK, I know the reason now.
>
>This regression we saw comes from scheduler load balancer.
>
>Pipe is a kind of workload that writer and reader will never run at the
>same time. They are synchronized by semaphore. One is always sleeping
>when the other end is working.
>
>To have cache hot, we do not wish to let writer and reader
>to be balanced to 2 cpus. That is why in fs/pipe.c, kernel use
>wake_up_interruptible_sync() instead of wake_up_interruptible to wakeup
>process.
>
>Now, load balancer is still balancing the processes if we have other
>any cpu idle.  Note that on an HT enabled x86 the load balancer will
>first balance the process to a cpu in SMT domain without cache miss
>penalty.
>
>So, when we run bw_pipe on a low load SMP machine, the kernel running in
>a way load balancer always trying to spread out 2 processes while the
>wake_up_interruptible_sync() is always trying to draw them back into
>1 cpu.
>
>Linus's patch will reduce the change to call wake_up_interruptible_sync()
>a lot.
>
>For bw_pipe writer or reader, the buffer size is 64k.  In a 16k page
>kernel. The old kernel will call wake_up_interruptible_sync 4 times but
>the new kernel will call wakeup only 1 time.
>
>Now the load balancer wins, processes are running on 2 cpus at most of
>the time.  They got a lot of cache miss penalty.
>
>To prove this, Just run 4 instances of bw_pipe on a 4 -way Tiger to let
>load balancer not so active.
>
>Or simply add some code at the top of main() in bw_pipe.c
>
>{
>  long affinity = 1;
>  sched_setaffinity(getpid(), sizeof(long), &affinity);
>}
>then make and run bw_pipe again.
>
>Now I get a throughput of 5GB...

-Tony
