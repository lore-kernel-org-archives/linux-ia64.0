From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Mar 2004 23:57:43 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <200403041657.43891.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 04 March 2004 4:41 pm, Keith Owens wrote:
> Why not use 'break 0' for gcc < 3.1?  No need to worry about which
> pages are protected.
> 
>         switch (break_num) {
>               case 0: /* unknown error (used by GCC for __builtin_abort()) */
>                 die_if_kernel("bugcheck!", regs, break_num);

Sounds reasonable to me, but I'm too chicken.  Propose a patch and
get David to take it, and I'll put it in 2.4.

