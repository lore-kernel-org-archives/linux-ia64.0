From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 23 Jun 2004 22:50:43 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406231650.43664.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 23 June 2004 8:26 am, Tian, Kevin wrote:
> I'm suspecting line in ia64_switch_to:
> 	/*
> 	* If we've already mapped this task's page, we can skip doing it
> again.
> 	*/
> (p6)	cmp.eq p7,p6=r27,r27 <----- Should here cmp.eq.unc be used
> instead? No time to test it now...

Your change evidently solves the problem, but I don't understand
how.  Can you enlighten me?  Here's the essence of the code:

	        cmp.eq p7,p6=r25,in0
	(p6)    cmp.eq p7,p6=r26,r27
	(p6)    br.cond.dpnt .map

As I understand it, adding ".unc" to the second cmp instruction
should only make a difference when p6=0.  In that case, after
the old cmp (no ".unc") we'd have p6=0 and p7=1, while after
the new cmp (with ".unc") we'd have p6=0 and p7=0.  But we
never test p7, so I don't see what difference it makes.
