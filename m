From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 06 Jun 2005 08:09:21 +0000
Subject: Re: Initialization of cr.dcr
Message-Id: <42A404B1.1010703@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A01CA2.8010209@hob.de>
In-Reply-To: <42A01CA2.8010209@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W schrieb:

>Patch to update the comments to reflect the actual code in cpu_init().
>
However the actual code distincts between TLB miss and other faults. The 
other faults are deferred.

Christian

>
>Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>Acked-by: David Mosberger-Tang <davidm@hpl.hp.com>
>
>--- linux-2.6.11/arch/ia64/kernel/setup.c.orig	2005-06-03 12:21:00.891940166 -0700
>+++ linux-2.6.11/arch/ia64/kernel/setup.c	2005-06-03 12:22:36.036470251 -0700
>@@ -720,7 +720,7 @@ cpu_init (void)
> 	ia64_set_kr(IA64_KR_PT_BASE, __pa(ia64_imva(empty_zero_page)));
> 
> 	/*
>-	 * Initialize default control register to defer all speculative faults.  The
>+	 * Initialize default control register not to defer speculative faults.  The
> 	 * kernel MUST NOT depend on a particular setting of these bits (in other words,
> 	 * the kernel must have recovery code for all speculative accesses).  Turn on
> 	 * dcr.lc as per recommendation by the architecture team.  Most IA-32 apps
>
>  
>

