From: Peter Keilty <peter.keilty@hp.com>
Date: Fri, 27 Apr 2007 13:35:44 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <4631FC30.2060602@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com> <20070427010253.GV6602@sequoia.sous-sol.org>
In-Reply-To: <20070427010253.GV6602@sequoia.sous-sol.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Wright <chrisw@sous-sol.org>
Cc: linux-ia64@vger.kernel.org, John Stultz <johnstul@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

Chris Wright wrote:

>* Peter Keilty (peter.keilty@hp.com) wrote:
>  
>
>>diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
>>index 6077300..35ad71f 100644
>>--- a/drivers/acpi/processor_idle.c
>>+++ b/drivers/acpi/processor_idle.c
>>@@ -480,10 +480,12 @@ #endif
>> 		/* Get end time (ticks) */
>> 		t2 = inl(acpi_gbl_FADT.xpm_timer_block.address);
>> 
>>+#ifndef CONFIG_IA64
>> #ifdef CONFIG_GENERIC_TIME
>> 		/* TSC halts in C2, so notify users */
>> 		mark_tsc_unstable();
>> #endif
>>+#endif
>>    
>>
>
>Is this a better description of the dependency?
>
>  #if defined (CONFIG_GENERIC_TIME) && defined (CONFIG_X86_TSC)
>  
>
yes, ok.

>  
>
>> 		/* Re-enable interrupts */
>> 		local_irq_enable();
>> 		current_thread_info()->status |= TS_POLLING;
>>@@ -522,10 +524,12 @@ #endif
>> 			acpi_set_register(ACPI_BITREG_ARB_DISABLE, 0);
>> 		}
>> 
>>+#ifndef CONFIG_IA64
>> #ifdef CONFIG_GENERIC_TIME
>> 		/* TSC halts in C3, so notify users */
>> 		mark_tsc_unstable();
>> #endif
>>+#endif
>>    
>>
>
>ditto
>
>  
>
>> 		/* Re-enable interrupts */
>> 		local_irq_enable();
>> 		current_thread_info()->status |= TS_POLLING;
>>diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
>>index 0be700f..5ea7d3e 100644
>>--- a/drivers/char/hpet.c
>>+++ b/drivers/char/hpet.c
>>@@ -29,6 +29,7 @@ #include <linux/wait.h>
>> #include <linux/bcd.h>
>> #include <linux/seq_file.h>
>> #include <linux/bitops.h>
>>+#include <linux/clocksource.h>
>> 
>> #include <asm/current.h>
>> #include <asm/uaccess.h>
>>@@ -51,8 +52,34 @@ #define	HPET_DRIFT	(500)
>> 
>> #define HPET_RANGE_SIZE		1024	/* from HPET spec */
>> 
>>+#if BITS_PER_LONG = 64
>>+#define	write_counter(V, MC)	writeq(V, MC)
>>+#define	read_counter(MC)	readq(MC)
>>+#else
>>+#define	write_counter(V, MC) 	writel(V, MC)
>>+#define	read_counter(MC)	readl(MC)
>>+#endif
>>+
>> static u32 hpet_nhpet, hpet_max_freq = HPET_USER_FREQ;
>> 
>>+static void __iomem *hpet_mc_ptr;
>>    
>>
>
>CodingStyle nit: we don't need all this _ptr...
>
>  
>
>>+static cycle_t read_hpet(void)
>>+{
>>+	return (cycle_t)read_counter((void __iomem *)hpet_mc_ptr);
>>+}
>>+
>>+static struct clocksource clocksource_hpet = {
>>+        .name           = "hpet",
>>+        .rating         = 300,
>>+        .read           = read_hpet,
>>+        .mask           = 0xffffffffffffffffLL,
>>+        .mult           = 0, /*to be caluclated*/
>>+        .shift          = 10,
>>+        .is_continuous  = 1,
>>+};
>>+static struct clocksource *hpet_clocksource_p;
>>    
>>
>
>and _p naming.
>
>  
>
>>+
>> /* A lock for concurrent access by app and isr hpet activity. */
>> static DEFINE_SPINLOCK(hpet_lock);
>> /* A lock for concurrent intermodule access to hpet and isr hpet activity. */
>>@@ -79,7 +106,7 @@ struct hpets {
>> 	struct hpets *hp_next;
>> 	struct hpet __iomem *hp_hpet;
>> 	unsigned long hp_hpet_phys;
>>-	struct time_interpolator *hp_interpolator;
>>+	struct clocksource *hp_clocksource;
>> 	unsigned long long hp_tick_freq;
>> 	unsigned long hp_delta;
>> 	unsigned int hp_ntimer;
>>@@ -94,13 +121,6 @@ #define	HPET_IE			0x0002	/* interrupt en
>> #define	HPET_PERIODIC		0x0004
>> #define	HPET_SHARED_IRQ		0x0008
>> 
>>-#if BITS_PER_LONG = 64
>>-#define	write_counter(V, MC)	writeq(V, MC)
>>-#define	read_counter(MC)	readq(MC)
>>-#else
>>-#define	write_counter(V, MC) 	writel(V, MC)
>>-#define	read_counter(MC)	readl(MC)
>>-#endif
>> 
>> #ifndef readq
>> static inline unsigned long long readq(void __iomem *addr)
>>@@ -737,27 +757,6 @@ static ctl_table dev_root[] = {
>> 
>> static struct ctl_table_header *sysctl_header;
>> 
>>-static void hpet_register_interpolator(struct hpets *hpetp)
>>-{
>>-#ifdef	CONFIG_TIME_INTERPOLATION
>>-	struct time_interpolator *ti;
>>-
>>-	ti = kzalloc(sizeof(*ti), GFP_KERNEL);
>>-	if (!ti)
>>-		return;
>>-
>>-	ti->source = TIME_SOURCE_MMIO64;
>>-	ti->shift = 10;
>>-	ti->addr = &hpetp->hp_hpet->hpet_mc;
>>-	ti->frequency = hpetp->hp_tick_freq;
>>-	ti->drift = HPET_DRIFT;
>>-	ti->mask = -1;
>>-
>>-	hpetp->hp_interpolator = ti;
>>-	register_time_interpolator(ti);
>>-#endif
>>-}
>>-
>> /*
>>  * Adjustment for when arming the timer with
>>  * initial conditions.  That is, main counter
>>@@ -909,7 +908,14 @@ int hpet_alloc(struct hpet_data *hdp)
>> 	}
>> 
>> 	hpetp->hp_delta = hpet_calibrate(hpetp);
>>-	hpet_register_interpolator(hpetp);
>>+
>>+	if (!hpet_clocksource_p) {
>>+        	clocksource_hpet.fsys_mmio_ptr = hpet_mc_ptr = &hpetp->hp_hpet->hpet_mc;
>>+        	clocksource_hpet.mult = clocksource_hz2mult(hpetp->hp_tick_freq,
>>+						clocksource_hpet.shift);
>>+        	clocksource_register(&clocksource_hpet);
>>+		hpet_clocksource_p = hpetp->hp_clocksource = &clocksource_hpet;
>>+	}
>>    
>>
>
>This looks like a change in behaviour for non-ia64.  Now i386 and x86_64
>will get this clocksource twice (and this one has a higher rating).
>Doesn't look like this will even compile since fsys_mmio_ptr (more
>  
>
Yes need to change setting for  fsys_mmio just for ia64.
I will check the load multiple clocksources, before it was limited.

>extraneous _ptr suffix) is ia64 only?  And sparc64 is left out in
>the cold.
>
>  
>
>> 	return 0;
>> }
>>@@ -995,7 +1001,7 @@ static int hpet_acpi_add(struct acpi_dev
>> 
>> static int hpet_acpi_remove(struct acpi_device *device, int type)
>> {
>>-	/* XXX need to unregister interpolator, dealloc mem, etc */
>>+	/* XXX need to unregister clocksource, dealloc mem, etc */
>> 	return -EINVAL;
>> }
>> 
>>diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
>>index daa4940..a20b4d6 100644
>>--- a/include/linux/clocksource.h
>>+++ b/include/linux/clocksource.h
>>@@ -61,6 +61,9 @@ struct clocksource {
>> 	u32 shift;
>> 	unsigned long flags;
>> 	cycle_t (*vread)(void);
>>+#ifdef CONFIG_IA64
>>+	void *fsys_mmio_ptr;	/* used by fsyscall asm code */
>>+#endif
>> 
>> 	/* timekeeping specific data, ignore */
>> 	cycle_t cycle_last, cycle_interval;
>>    
>>
