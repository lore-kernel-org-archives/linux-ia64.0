From: Linus Torvalds <torvalds@osdl.org>
Date: Tue, 18 Jan 2005 20:17:11 +0000
Subject: Re: pipe performance regression on ia64
Message-Id: <Pine.LNX.4.58.0501181200460.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501181741.j0IHfGf30058@unix-os.sc.intel.com>
 <Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org> <16877.21998.984277.551515@napali.hpl.hp.com>
In-Reply-To: <16877.21998.984277.551515@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, carl.staelin@hp.com
Cc: "Luck, Tony" <tony.luck@intel.com>, lmbench-users@bitmover.com, linux-ia64@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>



On Tue, 18 Jan 2005, David Mosberger wrote:
>
> >>>>> On Tue, 18 Jan 2005 10:11:26 -0800 (PST), Linus Torvalds <torvalds@osdl.org> said:
> 
>   Linus> I don't know how to make the benchmark look repeatable and
>   Linus> good, though.  The CPU affinity thing may be the right thing.
> 
> Perhaps it should be split up into three cases:
> 
> 	- producer/consumer pinned to the same CPU
> 	- producer/consumer pinned to different CPUs
> 	- producer/consumer lefter under control of the scheduler
> 
> The first two would let us observe any changes in the actual pipe
> code, whereas the 3rd case would tell us which case the scheduler is
> leaning towards (or if it starts doing something real crazy, like
> reschedule the tasks on different CPUs each time, we'd see a bandwith
> lower than case 2 and that should ring alarm bells).

Yes, that would be good.

However, I don't know who (if anybody) maintains lmbench any more. It 
might be Carl Staelin (added to cc), and there used to be a mailing list 
which may or may not be active any more..

[ Background for Carl (and/or lmbench-users): 

  The "pipe bandwidth" test ends up giving wildly fluctuating (and even
  when stable, pretty nonsensical, since they depend very strongly on the
  size of the buffer being used to do the writes vs the buffer size in the
  kernel) numbers purely depending on where the reader/writer got
  scheduled.

  So a recent kernel buffer management change made lmbench numbers vary 
  radically, ranging from huge improvements to big decreases. It would be 
  useful to see the numbers as a function of CPU selection on SMP (the 
  same is probably true also for the scheduling latency benchmark, which 
  is also extremely unstable on SMP).

  It's not just that it has big variance - you can't just average out many 
  runs. It has very "modal" operation, making averages meaningless. 

  A trivial thing that would work for most cases is just a simple (change 
  the "1" to whatever CPU-mask you want for some case)

	long affinity = 1;	/* bitmask: CPU0 only */
	sched_setaffinity(0, sizeof(long), &affinity);

  but I don't know what other OS's do, so it's obviously not portable ]

Hmm?

			Linus
