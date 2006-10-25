From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 25 Oct 2006 23:20:55 +0000
Subject: Re: ia64 acpi-cpufreq driver
Message-Id: <200610251720.55895.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EB12A50964762B4D8111D55B764A8454C57982@scsmsx413.amr.corp.intel.com>
In-Reply-To: <EB12A50964762B4D8111D55B764A8454C57982@scsmsx413.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Monday 23 October 2006 22:46, Pallipadi, Venkatesh wrote:
> >Section 8.4.4.1 (_PCT) of the 3.0 ACPI spec says:
> >
> >  OSPM performs processor performance transitions by writing
> >  the performance state-specific control value to a Performance
> >  Control Register (PERF_CTRL).
> >
> >According to one of our architecture guys, this means we really
> >ought to have an OpRegion driver that encapsulates the PAL_SET_PSTATE
> >call.
> 
> Actually it is slightly different from low_level_read and write. 
> Generic ACPI definition of ACPI PERF_CTRL and PERF_STATUS define 
> them as if they are registers. But, with FfixedHW, ACPI allows 
> architectures to implement this functionality in a native way.

I'd like to understand this better.  Something like the following
patch (not for inclusion, may not even compile) is what I'm
thinking.  This seems more in line with the spec intent.

Apart from details like "bit_width <= 8" vs. "bit_width = 8",
this should be functionally the same.  Are you saying it's different
because of those details, or is there a larger difference I don't
understand?

Nacked-by: Bjorn Helgaas

Index: work-1/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c
=================================--- work-1.orig/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c	2006-10-25 17:04:46.000000000 -0600
+++ work-1/arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c	2006-10-25 17:07:34.000000000 -0600
@@ -61,55 +61,16 @@
 static unsigned int acpi_pstate_strict;
 
 static int
-acpi_processor_write_port(
-	u16	port,
-	u8	bit_width,
-	u32	value)
-{
-	if (bit_width <= 8) {
-		outb(value, port);
-	} else if (bit_width <= 16) {
-		outw(value, port);
-	} else if (bit_width <= 32) {
-		outl(value, port);
-	} else {
-		return -ENODEV;
-	}
-	return 0;
-}
-
-static int
-acpi_processor_read_port(
-	u16	port,
-	u8	bit_width,
-	u32	*ret)
-{
-	*ret = 0;
-	if (bit_width <= 8) {
-		*ret = inb(port);
-	} else if (bit_width <= 16) {
-		*ret = inw(port);
-	} else if (bit_width <= 32) {
-		*ret = inl(port);
-	} else {
-		return -ENODEV;
-	}
-	return 0;
-}
-
-static int
 acpi_processor_set_performance (
 	struct cpufreq_acpi_io	*data,
 	unsigned int		cpu,
 	int			state)
 {
-	u16			port = 0;
-	u8			bit_width = 0;
 	int			i = 0;
-	int			ret = 0;
 	u32			value = 0;
 	int			retval;
 	struct acpi_processor_performance	*perf;
+	acpi_status		status;
 
 	dprintk("acpi_processor_set_performance\n");
 
@@ -132,16 +93,16 @@
 	 * control_register.
 	 */
 
-	port = perf->control_register.address;
-	bit_width = perf->control_register.bit_width;
 	value = (u32) perf->states[state].control;
 
-	dprintk("Writing 0x%08x to port 0x%04x\n", value, port);
+	dprintk("Writing 0x%08x to PERF_CTRL\n", value);
 
-	ret = acpi_processor_write_port(port, bit_width, value);
-	if (ret) {
-		dprintk("Invalid port width 0x%04x\n", bit_width);
-		return (ret);
+	status = acpi_hw_low_level_write(perf->control_register.bit_width,
+		value, perf->control_register);
+
+	if (ACPI_FAILURE(status)) {
+		dprintk("Failure writing PERF_CTRL\n");
+		return -ENODEV;
 	}
 
 	/*
@@ -157,17 +118,15 @@
 		 * before giving up.
 		 */
 
-		port = perf->status_register.address;
-		bit_width = perf->status_register.bit_width;
-
-		dprintk("Looking for 0x%08x from port 0x%04x\n",
-			(u32) perf->states[state].status, port);
+		dprintk("Looking for 0x%08x from PERF_CTRL\n",
+			(u32) perf->states[state].status);
 
 		for (i = 0; i < 100; i++) {
-			ret = acpi_processor_read_port(port, bit_width, &value);
-			if (ret) {	
-				dprintk("Invalid port width 0x%04x\n", bit_width);
-				return (ret);
+			status = acpi_hw_low_level_read(perf->control_register.bit_width,
+				&value, perf->control_register);
+			if (ACPI_FAILURE(status)) {
+				dprintk("Failure reading PERF_CTRL\n");
+				return -ENODEV;
 			}
 			if (value = (u32) perf->states[state].status)
 				break;
@@ -473,15 +432,6 @@
 		goto err_unreg;
 	}
 
-	if ((perf->control_register.space_id != ACPI_ADR_SPACE_SYSTEM_IO) ||
-	    (perf->status_register.space_id != ACPI_ADR_SPACE_SYSTEM_IO)) {
-		dprintk("Unsupported address space [%d, %d]\n",
-			(u32) (perf->control_register.space_id),
-			(u32) (perf->status_register.space_id));
-		result = -ENODEV;
-		goto err_unreg;
-	}
-
 	/* alloc freq_table */
 	data->freq_table = kmalloc(sizeof(struct cpufreq_frequency_table) * (perf->state_count + 1), GFP_KERNEL);
 	if (!data->freq_table) {

