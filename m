From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 04 Mar 2005 22:33:56 +0000
Subject: RE: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <200503042233.j24MXug29211@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Friday, March 04, 2005 11:58 AM
> >You tell me what to do.
>
> At the moment I'm hoping somebody smarter will chime into this thread
> (either to point out a great solution, or to tell me that I'm a dork
> and this code is perfectly reasonable, so I should quit quibbling).
>
> Overall the patch is great ... it's solving a real problem in an elegant
> way.  It's just this little corner of how to shrink the quicklists that
> I'm trying to get right.

One other possible solution I can think of is to use schedule_delayed_work
API.  You can schedule one per node every one second interval and have the
work function re-arm itself.  It has several pros:

1. Addresses the concern that Tony has with SETI eating up all the idle
   ticks and check_pgt_cache() may never get a chance to run.
2. once work is scheduled, you don't need to dance with batch count.
   Just keep on freeing in one while loop since it is running in a kernel
   thread.
3. Potentially, call to check_pgt_cache from tlb_finish_mmu() can be
   removed, making process exit faster.
4. And last, probably not important, addresses my concern of broken model
   (freeing memory in idle loop).

Just my 2 cents, only worth what's on the paper.

- Ken


