From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Mar 2004 00:05:31 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <16455.50251.62626.925964@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Mar 2004 16:57:43 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Thursday 04 March 2004 4:41 pm, Keith Owens wrote:

  >> Why not use 'break 0' for gcc < 3.1?  No need to worry about
  >> which pages are protected.

  >> switch (break_num) { case 0: /* unknown error (used by GCC for
  >> __builtin_abort()) */ die_if_kernel("bugcheck!", regs,
  >> break_num);

  Bjorn> Sounds reasonable to me, but I'm too chicken.  Propose a
  Bjorn> patch and get David to take it, and I'll put it in 2.4.

I don't think it's worth changing (2.9x is out for 2.6 anyhow, and I
doubt anyone is using GCC 3.0 for real work; if you do, you're
probably in lots of trouble for other reasons!).  Besides, one
disadvantage of using "break 0" is that it will make Ski stop
immediately, which isn't what you want.

	--david
