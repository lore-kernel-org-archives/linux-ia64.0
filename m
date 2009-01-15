From: Greg KH <greg@kroah.com>
Date: Thu, 15 Jan 2009 18:48:32 +0000
Subject: Re: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <20090115184832.GE10674@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com>
In-Reply-To: <20090106162741.GA7991@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Gregory Haskins <ghaskins@novell.com>, Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@gmail.com>, Robin Holt <holt@sgi.com>

On Tue, Jan 06, 2009 at 10:27:41AM -0600, Dimitri Sivanich wrote:
> Turn on CONFIG_HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN.
> 
> SGI Altix has unsynchronized itc clocks.  This results in rq->clock
> occasionally being set to a time in the past by a remote cpu.
> 
> Note that it is possible that this problem may exist for other ia64
> machines as well, based on the following comment for sched_clock() in
> arch/ia64/kernel/head.S:
> 
>  * Return a CPU-local timestamp in nano-seconds.  This timestamp is
>  * NOT synchronized across CPUs its return value must never be
>  * compared against the values returned on another CPU.  The usage in
>  * kernel/sched.c ensures that.
> 
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
> 
> ---
> 
> Greg, if everyone is OK with this patch, this should also be applied
> to all stable trees starting with 2.6.26.

What is the status of this going into Linus's tree?

thanks,

greg k-h
