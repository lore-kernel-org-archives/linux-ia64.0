From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 May 2005 20:48:51 +0000
Subject: RE: heads up: apparent GAS bug in current (CVS) binutils
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F037CE620@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
In-Reply-To: <200505122155.j4CLteGX024882@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>+++ linux/arch/ia64/kernel/smpboot.c	2005-05-13 
>-struct pt_regs * __devinit idle_regs(struct pt_regs *regs)
>+struct pt_regs *
>+__devinit __comdatfunc (idle_regs)
>+idle_regs(struct pt_regs *regs)

>+++ linux/kernel/fork.c	2005-05-13 13:19:40.000000000 -0700
>-struct pt_regs * __devinit __attribute__((weak)) 
>idle_regs(struct pt_regs *regs)
>+struct pt_regs *
>+__devinit __comdatfunc (idle_regs)
>+idle_regs(struct pt_regs *regs)

So is there some deeper magic that I don't understand, or is this
wrong?  After this patch is applied, both of these definitions look
identical to me.  So how does the linker know which one to use?

-Tony
