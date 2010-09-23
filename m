From: Greg KH <greg@kroah.com>
Date: Thu, 23 Sep 2010 18:16:41 +0000
Subject: Re: [stable] [IA64 PATCH for v2.6.32 to v2.6.35] ia64: fix siglock
Message-Id: <20100923181641.GJ23040@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c927cb2184948077a@agluck-desktop.sc.intel.com>
In-Reply-To: <4c927cb2184948077a@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 16, 2010 at 01:23:14PM -0700, Luck, Tony wrote:
> When ia64 converted to using ticket locks, an inline implementation
> of trylock/unlock in fsys.S was missed.  This was not noticed because
> in most circumstances it simply resulted in using the slow path because
> the siglock was apparently not available (under old spinlock rules).
> 
> Problems occur when the ticket spinlock has value 0x0 (when first
> initialised, or when it wraps around). At this point the fsys.S
> code acquires the lock (changing the 0x0 to 0x1. If another process
> attempts to get the lock at this point, it will change the value from
> 0x1 to 0x2 (using new ticket lock rules). Then the fsys.S code will
> free the lock using old spinlock rules by writing 0x0 to it. From
> here a variety of bad things can happen.
> 
> Fix to use the new ticket lock algorithm.
> 
> Cc: Petr Tesarik <ptesarik@suse.cz>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> ---
> 
> This went upstream in two pieces - there was a bug in the first attempt
> (my code), the second (by Petr) fixes the bug (and also makes the code
> much prettier).  Patch below is the combination of both so we don't
> make a bisection trap for people to fall into. If this violates stable
> rules, then feel free to just cherry pick the two commits.
> 
> commit f574c843191728d9407b766a027f779dcd27b272
>     [IA64] fix siglock
> commit 2d2b6901649a62977452be85df53eda2412def24
>     [IA64] Optimize ticket spinlocks in fsys_rt_sigprocmask

I just applied these two patches in-order, to make it more obvious as to
where things came from.

thanks,

greg k-h
