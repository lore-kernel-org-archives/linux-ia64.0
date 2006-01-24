From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jan 2006 21:51:12 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124215112.GA17819@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 24, 2006 at 03:12:48PM -0600, Brent Casavant wrote:
> > But I'd also like to see how invasive a "task has migrated" bit in
> > thread_info.flags (as suggested elsewhere in this thread) gets to
> > be.
> 
> I'll be happy to do this if you really want.  That said, having stared
> at this code enough now, I don't believe it would be a better solution.

You are probably right.

> So, does this look better?

> +	.last_cpu	= 0,			\

How does .last_cpu get propagated to new processes, and what is
it initialized to?  Right now it looks like there is an odd
quirk that we'll call platform_switch_from() as each process starts
running for the first time [or is the whole thread_info structure
copied from the parent someplace that I didn't notice].

-Tony
