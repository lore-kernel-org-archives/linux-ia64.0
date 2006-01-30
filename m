From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Mon, 30 Jan 2006 11:48:43 +0000
Subject: [PATCH] Add wakeup from S5 state without defining CONFIG_ACPI_SLEEP
Message-Id: <87fyn6ey1w.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi <linux-acpi@vger.kernel.org>, "Brown, Len" <len.brown@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

Hi, 

Recently I tried wakeup on LAN from S5 state on my ia64 box, but I couldn't
accomplish it. So I searched ACPI driver and found out wakeup capability is
supported if and only if CONFIG_ACPI_SLEEP is defined (it isn't defined on
ia64 so far). I also found out ACPI specification says as follow:

 1. the S5 state is not a sleeping state (it is a G2 state)

 2. OSPM does not disable wake events before setting the SLP_EN bit when
    entering the S5 system state. This provides support for remote management
    initiatives by enabling Remote Start capability. An ACPI-compliant OS must
    provide an end user accessible mechanism for disabling all wake devices,
    with the exception of the systme power button, from a single point in the
    user interface.

But currently if CONFIG_ACPI_SLEEP is not defined, all wakeup events are
disabled when entring the S5 system state and we can't toggle enable/disable
wakeup GPEs. So I made ACPI subsystem provide wake up capability even if
CONFIG_ACPI_SLEEP is not set. I tested it on my ia64 box and I also confirmed
it doesn't break wakeup from S5 capability on i386 box.

Thanks,

Satoru Takeuchi

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

Currently wakeup capability is available if and only if CONFIG_ACPI_SLEEP=y.
But S5 is not a sleep state. This patch makes ACPI subsystem to be able to
wakeup from S5 state even if sleep mode is not supported.

 drivers/acpi/sleep/Makefile   |    3 +--
 drivers/acpi/sleep/poweroff.c |    1 +
 drivers/acpi/sleep/proc.c     |   16 ++++++++++++++++
 drivers/acpi/sleep/wakeup.c   |    2 ++
 4 files changed, 20 insertions(+), 2 deletions(-)

Index: linux-2.6.16-rc1/drivers/acpi/sleep/Makefile
=================================--- linux-2.6.16-rc1.orig/drivers/acpi/sleep/Makefile	2006-01-30 15:54:37.000000000 +0900
+++ linux-2.6.16-rc1/drivers/acpi/sleep/Makefile	2006-01-30 17:24:16.000000000 +0900
@@ -1,5 +1,4 @@
-obj-y					:= poweroff.o wakeup.o
+obj-y					:= poweroff.o wakeup.o proc.o
 obj-$(CONFIG_ACPI_SLEEP)		+= main.o
-obj-$(CONFIG_ACPI_SLEEP_PROC_FS)	+= proc.o
 
 EXTRA_CFLAGS += $(ACPI_CFLAGS)
Index: linux-2.6.16-rc1/drivers/acpi/sleep/proc.c
=================================--- linux-2.6.16-rc1.orig/drivers/acpi/sleep/proc.c	2006-01-30 15:54:37.000000000 +0900
+++ linux-2.6.16-rc1/drivers/acpi/sleep/proc.c	2006-01-30 17:24:16.000000000 +0900
@@ -70,6 +70,7 @@
 }
 #endif				/* CONFIG_ACPI_SLEEP_PROC_SLEEP */
 
+#ifdef	CONFIG_ACPI_SLEEP
 static int acpi_system_alarm_seq_show(struct seq_file *seq, void *offset)
 {
 	u32 sec, min, hr;
@@ -339,6 +340,7 @@
       end:
 	return_VALUE(result ? result : count);
 }
+#endif				/* CONFIG_ACPI_SLEEP */
 
 extern struct list_head acpi_wakeup_device_list;
 extern spinlock_t acpi_device_lock;
@@ -357,6 +359,10 @@
 
 		if (!dev->wakeup.flags.valid)
 			continue;
+#ifndef	CONFIG_ACPI_SLEEP
+		if (dev->wakeup.sleep_state != ACPI_STATE_S5)
+			continue;
+#endif
 		spin_unlock(&acpi_device_lock);
 		seq_printf(seq, "%4s	%4d		%s%8s\n",
 			   dev->pnp.bus_id,
@@ -394,6 +400,10 @@
 		    container_of(node, struct acpi_device, wakeup_list);
 		if (!dev->wakeup.flags.valid)
 			continue;
+#ifndef	CONFIG_ACPI_SLEEP
+		if (dev->wakeup.sleep_state != ACPI_STATE_S5)
+			continue;
+#endif
 
 		if (!strncmp(dev->pnp.bus_id, str, 4)) {
 			dev->wakeup.state.enabled @@ -452,6 +462,7 @@
 };
 #endif				/* CONFIG_ACPI_SLEEP_PROC_SLEEP */
 
+#ifdef	CONFIG_ACPI_SLEEP
 static struct file_operations acpi_system_alarm_fops = {
 	.open = acpi_system_alarm_open_fs,
 	.read = seq_read,
@@ -467,6 +478,7 @@
 
 	return ACPI_INTERRUPT_HANDLED;
 }
+#endif				/* CONFIG_ACPI_SLEEP */
 
 static int acpi_sleep_proc_init(void)
 {
@@ -484,12 +496,14 @@
 		entry->proc_fops = &acpi_system_sleep_fops;
 #endif
 
+#ifdef	CONFIG_ACPI_SLEEP
 	/* 'alarm' [R/W] */
 	entry  	    create_proc_entry("alarm", S_IFREG | S_IRUGO | S_IWUSR,
 			      acpi_root_dir);
 	if (entry)
 		entry->proc_fops = &acpi_system_alarm_fops;
+#endif
 
 	/* 'wakeup device' [R/W] */
 	entry @@ -498,7 +512,9 @@
 	if (entry)
 		entry->proc_fops = &acpi_system_wakeup_device_fops;
 
+#ifdef	CONFIG_ACPI_SLEEP
 	acpi_install_fixed_event_handler(ACPI_EVENT_RTC, rtc_handler, NULL);
+#endif
 	return 0;
 }
 
Index: linux-2.6.16-rc1/drivers/acpi/sleep/wakeup.c
=================================--- linux-2.6.16-rc1.orig/drivers/acpi/sleep/wakeup.c	2006-01-30 15:54:37.000000000 +0900
+++ linux-2.6.16-rc1/drivers/acpi/sleep/wakeup.c	2006-01-30 17:24:16.000000000 +0900
@@ -48,6 +48,7 @@
 	}
 	spin_unlock(&acpi_device_lock);
 }
+#endif
 
 /**
  * acpi_enable_wakeup_device - enable wakeup devices
@@ -100,6 +101,7 @@
 	spin_unlock(&acpi_device_lock);
 }
 
+#ifdef CONFIG_ACPI_SLEEP
 /**
  * acpi_disable_wakeup_device - disable devices' wakeup capability
  *	@sleep_state:	ACPI state
Index: linux-2.6.16-rc1/drivers/acpi/sleep/poweroff.c
=================================--- linux-2.6.16-rc1.orig/drivers/acpi/sleep/poweroff.c	2006-01-30 17:23:45.000000000 +0900
+++ linux-2.6.16-rc1/drivers/acpi/sleep/poweroff.c	2006-01-30 17:25:21.000000000 +0900
@@ -47,6 +47,7 @@
 	/* acpi_sleep_prepare(ACPI_STATE_S5) should have already been called */
 	printk("%s called\n", __FUNCTION__);
 	local_irq_disable();
+	acpi_enable_wakeup_device(ACPI_STATE_S5);
 	/* Some SMP machines only can poweroff in boot CPU */
 	acpi_enter_sleep_state(ACPI_STATE_S5);
 }
