From: Christophe Lucas <clucas@rotomalug.org>
Date: Wed, 23 Mar 2005 10:02:09 +0000
Subject: Re: [patch 1/1] printk : arch/ia64/kernel/smp.c
Message-Id: <20050323100209.GA9206@rhum.iomeda.fr>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ftEhullJWpWg/VHq"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050319131906.E934A1F245@trashy.coderock.org>
In-Reply-To: <20050319131906.E934A1F245@trashy.coderock.org>
To: linux-ia64@vger.kernel.org


--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Luck, Tony (tony.luck@intel.com) wrote:
> > 	if (cpuid == me) {
> >-		printk("%s: trying to call self\n", __FUNCTION__);
> >+		printk(KERN_INFO "%s: trying to call self\n", __FUNCTION__);
> > 		put_cpu();
> > 		return -EBUSY;
> > 	}
> 
> I think this is a bit higher priority than KERN_INFO.  If we
> get here, then someone did something wrong at a higher level,
> and they may be disapponited that the function they want called
> isn't going to be called.
> 
> Perhaps KERN_WARNING would be more appropriate?
> 
> It might also be kind to anyone trying to debug this to print
> the "func" argument.
> 
> -Tony
> 

Perhaps this could do the job:



--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch-linux-2.6.12-rc1_arch_ia64_kernel_smp.c.diff"

diff -uprN -X dontdiff a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
--- a/arch/ia64/kernel/smp.c	2005-03-18 02:34:36.000000000 +0100
+++ b/arch/ia64/kernel/smp.c	2005-03-23 10:35:18.000000000 +0100
@@ -269,7 +269,7 @@ smp_call_function_single (int cpuid, voi
 	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
 	if (cpuid == me) {
-		printk("%s: trying to call self\n", __FUNCTION__);
+		printk(KERN_WARNING "%s: trying to call self with info:%08x\n", __FUNCTION__, info);
 		put_cpu();
 		return -EBUSY;
 	}

--ftEhullJWpWg/VHq--

