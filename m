From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 03 Feb 2006 17:43:29 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <200602031743.k13HhUg15568@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Thursday, February 02, 2006 1:46 PM
> The current state of the tree is that Andrew added the patch
> to make the definition of printk_clock() in kernel/printk.c
> "__attribute__((weak))" so that architectures could override
> with their own version.  Default version uses sched_clock().

Why don't we look at ar.k3, it contains per_cpu base address.
If it has a none zero value, then it is initialized by
per_cpu_init and is safe to call sched_clock.

- Ken


--- ./arch/ia64/kernel/time.c.orig	2006-02-03 10:10:10.291334310 -0800
+++ ./arch/ia64/kernel/time.c	2006-02-03 10:23:35.944644753 -0800
@@ -278,3 +278,10 @@ udelay (unsigned long usecs)
 	}
 }
 EXPORT_SYMBOL(udelay);
+
+unsigned long long printk_clock(void)
+{
+	if (ia64_get_kr(IA64_KR_PER_CPU_DATA))
+		return sched_clock();
+	return 0;
+}
--- ./arch/ia64/kernel/head.S.orig	2006-02-03 10:24:57.431948442 -0800
+++ ./arch/ia64/kernel/head.S	2006-02-03 10:30:54.306944070 -0800
@@ -352,6 +352,7 @@ start_ap:
 	mov ar.rsc=0		// place RSE in enforced lazy mode
 	;;
 	loadrs			// clear the dirty partition
+	mov ar.k3=r0		// clear physical per-CPU base
 	;;
 	mov ar.bspstore=r2	// establish the new RSE stack
 	;;


