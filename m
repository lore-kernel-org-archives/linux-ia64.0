From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 23 Jun 2005 22:18:53 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <17083.13645.585589.85631@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 23 Jun 2005 14:30:20 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> David Mosberger wrote:
  >>
  Russ> -ENTRY(interrupt) +GLOBAL_ENTRY(interrupt)
  >>  Please don't create such name-space pollution.

  >> AFAICS, you should be able to use ia64_ivt and the architected
  >> offset for the external-interrupt handler instead.

  Russ> I assume you mean usage like in
  Russ> arch/ia64/oprofile/backtrace.c, so the usage in mca_drv.c
  Russ> would be along the lines of:

  Russ> 	extern char ia64_ivt[];

  Russ> 	if (psr1->cpl != 0 || (pmsa->pmsa_iip >= (unsigned
  Russ> long)ia64_ivt+0x3000 &&

  Russ> Do you have the same objection for interrupt_pnr?  If so, what
  Russ> is the best way to calculate the offset in ivt.S (which looks
  Russ> hardcoded for other routines)?

I thought interrupt_pnr was at the end of the vector.  Now that I look
closer, the whole thing looks rather doubious/fragile to me.  What
exactly are you trying to do there?

	--david
