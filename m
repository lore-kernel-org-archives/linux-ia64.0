From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 06 Feb 2006 18:14:14 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <20060206181414.GA27657@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 03, 2006 at 09:43:29AM -0800, Chen, Kenneth W wrote:
> Why don't we look at ar.k3, it contains per_cpu base address.
> If it has a none zero value, then it is initialized by
> per_cpu_init and is safe to call sched_clock.

We also need to check whether ar.itc is synchronized on different
cpus ... if it isn't, then sched_clock() is useless.  Here's a
simple extension of your patch that does this, falling back to using
a jiffie based clock (which means you'd only have HZ resolution on
systems where there is drift).

If that isn't good enough, then I'd be happy to see a patch that
does a lockless interpolation.

-Tony


diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index fbc7ea3..99cfef8 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -352,6 +352,7 @@ start_ap:
 	mov ar.rsc=0		// place RSE in enforced lazy mode
 	;;
 	loadrs			// clear the dirty partition
+	mov ar.k3=r0		// clear physical per-CPU base
 	;;
 	mov ar.bspstore=r2	// establish the new RSE stack
 	;;
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 028a2b9..648c116 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -278,3 +278,13 @@ udelay (unsigned long usecs)
 	}
 }
 EXPORT_SYMBOL(udelay);
+
+unsigned long long printk_clock(void)
+{
+	if (sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT) {
+		return (unsigned long long)(jiffies_64 - INITIAL_JIFFIES) *
+			(1000000000/HZ);
+	} else if (ia64_get_kr(IA64_KR_PER_CPU_DATA))
+		return sched_clock();
+	return 0;
+}
