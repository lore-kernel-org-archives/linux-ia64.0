From: Robin Holt <holt@sgi.com>
Date: Fri, 04 Mar 2005 16:25:49 +0000
Subject: Re: [Patch 0/3] Page table quicklist fixups Rev 3.
Message-Id: <20050304162548.GA15756@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050303212359.GA732@lnx-holt.americas.sgi.com>
In-Reply-To: <20050303212359.GA732@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 03, 2005 at 01:57:49PM -0800, Luck, Tony wrote:
> I'm also a bit uncomfortable with:
> 
> +		preempt_enable();
> +		preempt_disable();
> 
> For a kernel with CONFIG_PREEMPT=n, this is a no-op ... so if there
> is a ton of extra pages on the quicklist, we'll loop freeing 16 at
> a time and re-computing how many to free, with no pause to take a
> breath (or a clock tick).

Someone pointed out that your concern may actually be the "or a clock
tick" portion of this statement.  We are not disabling interrupts.
We are disabling and enabling preemption.  Was that your concern or am
I still missing the picture?

If that concern, I will fall back on the "I am not making it worse defense"
because the shrink used to go from high water to low water mark.  This would
result in thousands of pages being freed.  That, of course is based on the
2.4 kernel since that is the last series that actually used the quicklists.

Robin
