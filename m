From: Jes Sorensen <jes@sgi.com>
Date: Tue, 07 Feb 2006 11:11:48 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <yq0lkwnmnij.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "tony" = Luck, Tony <tony.luck@intel.com> writes:

tony> We also need to check whether ar.itc is synchronized on
tony> different cpus ... if it isn't, then sched_clock() is useless.
tony> Here's a simple extension of your patch that does this, falling
tony> back to using a jiffie based clock (which means you'd only have
tony> HZ resolution on systems where there is drift).

tony> If that isn't good enough, then I'd be happy to see a patch that
tony> does a lockless interpolation.

Me too! me too! ;-)

I've never really thought of this feature as being important, but it
might be good for debugging so getting the extra resolution where
possible is probably a good thing<tm>.

What about this, it uses a function pointer that can be updated by the
machine specific code so architectures which have an alternative
reliable clock source can use that instead of falling back to the
jiffies based implementation?

Cheers,
Jes

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index fbc7ea3..99cfef8 100644
 arch/ia64/kernel/head.S     |    1 +
 arch/ia64/kernel/setup.c    |    4 ++++
 arch/ia64/kernel/time.c     |   27 +++++++++++++++++++++++++++
 arch/ia64/sn/kernel/setup.c |   40 +++++++++++++++++++++++++++-------------
 4 files changed, 59 insertions(+), 13 deletions(-)

Index: linux-2.6/arch/ia64/kernel/head.S
=================================--- linux-2.6.orig/arch/ia64/kernel/head.S
+++ linux-2.6/arch/ia64/kernel/head.S
@@ -352,6 +352,7 @@
 	mov ar.rsc=0		// place RSE in enforced lazy mode
 	;;
 	loadrs			// clear the dirty partition
+	mov ar.k3=r0		// clear physical per-CPU base
 	;;
 	mov ar.bspstore=r2	// establish the new RSE stack
 	;;
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c
+++ linux-2.6/arch/ia64/kernel/setup.c
@@ -71,6 +71,8 @@
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
 
+extern void ia64_setup_printk_clock(void);
+
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
 DEFINE_PER_CPU(unsigned long, ia64_phys_stacked_size_p8);
@@ -445,6 +447,8 @@
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
+	ia64_setup_printk_clock();
+
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();
 
Index: linux-2.6/arch/ia64/kernel/time.c
=================================--- linux-2.6.orig/arch/ia64/kernel/time.c
+++ linux-2.6/arch/ia64/kernel/time.c
@@ -278,3 +278,30 @@
 	}
 }
 EXPORT_SYMBOL(udelay);
+
+static unsigned long long ia64_itc_printk_clock(void)
+{
+	if (ia64_get_kr(IA64_KR_PER_CPU_DATA))
+		return sched_clock();
+	return 0;
+}
+
+static unsigned long long ia64_default_printk_clock(void)
+{
+	return (unsigned long long)(jiffies_64 - INITIAL_JIFFIES) *
+		(1000000000/HZ);
+}
+
+unsigned long long (*ia64_printk_clock)(void) = &ia64_default_printk_clock;
+
+unsigned long long printk_clock(void)
+{
+	return ia64_printk_clock();
+}
+
+void __init
+ia64_setup_printk_clock(void)
+{
+	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT))
+		ia64_printk_clock = ia64_itc_printk_clock;
+}
Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c
+++ linux-2.6/arch/ia64/sn/kernel/setup.c
@@ -67,6 +67,7 @@
 extern void (*ia64_mark_idle) (int);
 extern void snidle(int);
 extern unsigned char acpi_kbd_controller_present;
+extern unsigned long long (*ia64_printk_clock)(void);
 
 unsigned long sn_rtc_cycles_per_second;
 EXPORT_SYMBOL(sn_rtc_cycles_per_second);
@@ -372,6 +373,16 @@
 	}
 }
 
+static unsigned long sn2_rtc_initial;
+
+static unsigned long long ia64_sn2_printk_clock(void)
+{
+	unsigned long rtc_now = rtc_time();
+
+	return (rtc_now - sn2_rtc_initial) *
+		(1000000000 / sn_rtc_cycles_per_second);
+}
+
 /**
  * sn_setup - SN platform setup routine
  * @cmdline_p: kernel command line
@@ -386,6 +397,7 @@
 	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
+	sn2_rtc_initial = rtc_time();
 	ia64_sn_plat_set_error_handling_features();	// obsolete
 	ia64_sn_set_os_feature(OSF_MCA_SLV_TO_OS_INIT_SLV);
 	ia64_sn_set_os_feature(OSF_FEAT_LOG_SBES);
@@ -437,19 +449,6 @@
 	 */
 	build_cnode_tables();
 
-	/*
-	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
-	 * support here so we don't have to listen to failed keyboard probe
-	 * messages.
-	 */
-	if (version <= 0x0209 && acpi_kbd_controller_present) {
-		printk(KERN_INFO "Disabling legacy keyboard support as prom "
-		       "is too old and doesn't provide FADT\n");
-		acpi_kbd_controller_present = 0;
-	}
-
-	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
-
 	status  	    ia64_sal_freq_base(SAL_FREQ_BASE_REALTIME_CLOCK, &ticks_per_sec,
 			       &drift);
@@ -463,6 +462,21 @@
 
 	platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
 
+	ia64_printk_clock = ia64_sn2_printk_clock;
+
+	/*
+	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
+	 * support here so we don't have to listen to failed keyboard probe
+	 * messages.
+	 */
+	if (version <= 0x0209 && acpi_kbd_controller_present) {
+		printk(KERN_INFO "Disabling legacy keyboard support as prom "
+		       "is too old and doesn't provide FADT\n");
+		acpi_kbd_controller_present = 0;
+	}
+
+	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
+
 	/*
 	 * we set the default root device to /dev/hda
 	 * to make simulation easy
