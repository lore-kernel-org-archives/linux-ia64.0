From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 29 Sep 2006 18:58:31 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <200609291258.31881.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <14425.1159496284@kao2.melbourne.sgi.com> <200609291057.41529.bjorn.helgaas@hp.com> <20060929180110.GA4021@intel.com>
In-Reply-To: <20060929180110.GA4021@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Keith Owens <kaos@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday 29 September 2006 12:01, Luck, Tony wrote:
> On Fri, Sep 29, 2006 at 10:57:41AM -0600, Bjorn Helgaas wrote:
> >   acpi_parse_fadt: acpi_kbd_controller_present 0
> 
> The logic in the kernel seems backwards here though.  We start
> by assuming there is a keyboard, then when parsing the FADT
> we reset this assumption if the BAF_8042_KEYBOARD_CONTROLLER
> bit isn't set.  Which in turn forced SGI to include some
> workaround code for their older PROM (which doesn't provide
> the FADT table).
> 
> There's also a risk that if some code might get added that
> runs before we parse FADT that could be confused into thinking
> that the keyboard is present.
> 
> Wouldn't it be simpler/better to assume there is no keyboard until
> we find positive evidence that there is one?

I added the original check, but I can't remember the reason I
initialized acpi_kbd_controller_present to 1.  Possibly just
timidity.

At the time, it was used in pc_keyb.c to avoid a blind probe.
That usage no longer exists.  i8042 now registers a regular
PNP driver with the appropriate PNP IDs.

Nobody actually uses acpi_kbd_controller_present or
acpi_legacy_devices anymore.  Maybe the best thing is to
just remove both of them.  Then the Keith can add back
the acpi_kbd_controller_present part to the kdb patch if
he decides that's the best route.



ia64: remove unused acpi_kbd_controller_present, acpi_legacy_devices

Nobody uses either one anymore.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-1/arch/ia64/kernel/acpi.c
=================================--- work-1.orig/arch/ia64/kernel/acpi.c	2006-09-27 16:33:05.000000000 -0600
+++ work-1/arch/ia64/kernel/acpi.c	2006-09-29 12:57:20.000000000 -0600
@@ -64,9 +64,6 @@
 void (*pm_power_off) (void);
 EXPORT_SYMBOL(pm_power_off);
 
-unsigned char acpi_kbd_controller_present = 1;
-unsigned char acpi_legacy_devices;
-
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
@@ -628,12 +625,6 @@
 
 	fadt = (struct fadt_descriptor *)fadt_header;
 
-	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
-		acpi_kbd_controller_present = 0;
-
-	if (fadt->iapc_boot_arch & BAF_LEGACY_DEVICES)
-		acpi_legacy_devices = 1;
-
 	acpi_register_gsi(fadt->sci_int, ACPI_LEVEL_SENSITIVE, ACPI_ACTIVE_LOW);
 	return 0;
 }
Index: work-1/arch/ia64/sn/kernel/setup.c
=================================--- work-1.orig/arch/ia64/sn/kernel/setup.c	2006-09-27 16:33:06.000000000 -0600
+++ work-1/arch/ia64/sn/kernel/setup.c	2006-09-29 12:44:28.000000000 -0600
@@ -65,7 +65,6 @@
 extern unsigned long last_time_offset;
 extern void (*ia64_mark_idle) (int);
 extern void snidle(int);
-extern unsigned char acpi_kbd_controller_present;
 extern unsigned long long (*ia64_printk_clock)(void);
 
 unsigned long sn_rtc_cycles_per_second;
@@ -452,17 +451,6 @@
 
 	ia64_printk_clock = ia64_sn2_printk_clock;
 
-	/*
-	 * Old PROMs do not provide an ACPI FADT. Disable legacy keyboard
-	 * support here so we don't have to listen to failed keyboard probe
-	 * messages.
-	 */
-	if (is_shub1() && version <= 0x0209 && acpi_kbd_controller_present) {
-		printk(KERN_INFO "Disabling legacy keyboard support as prom "
-		       "is too old and doesn't provide FADT\n");
-		acpi_kbd_controller_present = 0;
-	}
-
 	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
 
 	/*
