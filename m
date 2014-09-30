From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:41 +0000
Subject: [RFC PATCH 01/16] kernel: Add support for poweroff handler call chain
Message-Id: <1412100056-15517-2-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Various drivers implement architecture and/or device specific means to
remove power from the system.  For the most part, those drivers set the
global variable pm_power_off to point to a function within the driver.

This mechanism has a number of drawbacks.  Typically only one scheme
to remove power is supported (at least if pm_power_off is used).
At least in theory there can be multiple means remove power, some of
which may be less desirable. For example, some mechanisms may only
power off the CPU or the CPU card, while another may power off the
entire system.  Others may really just execute a restart sequence
or drop into the ROM monitor. Using pm_power_off can also be racy
if the function pointer is set from a driver built as module, as the
driver may be in the process of being unloaded when pm_power_off is
called. If there are multiple poweroff handlers in the system, removing
a module with such a handler may inadvertently reset the pointer to
pm_power_off to NULL, leaving the system with no means to remove power.

Introduce a system poweroff handler call chain to solve the described
problems.  This call chain is expected to be executed from the
architecture specific machine_power_off() function.  Drivers providing
system poweroff functionality are expected to register with this call chain.
By using the priority field in the notifier block, callers can control
poweroff handler execution sequence and thus ensure that the poweroff
handler with the optimal capabilities to remove power for a given system
is called first.

Cc: Andrew Morton <akpm@linux-foundation.org>
cc: Heiko Stuebner <heiko@sntech.de>
Cc: Romain Perier <romain.perier@gmail.com>
Cc: James E.J. Bottomley <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Sebastian Reichel <sre@kernel.org>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: Lee Jones <lee.jones@linaro.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 include/linux/reboot.h |  4 +++
 kernel/reboot.c        | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/include/linux/reboot.h b/include/linux/reboot.h
index 67fc8fc..b172951 100644
--- a/include/linux/reboot.h
+++ b/include/linux/reboot.h
@@ -38,6 +38,10 @@ extern int reboot_force;
 extern int register_reboot_notifier(struct notifier_block *);
 extern int unregister_reboot_notifier(struct notifier_block *);
 
+extern int register_poweroff_handler(struct notifier_block *);
+extern int unregister_poweroff_handler(struct notifier_block *);
+extern void do_kernel_poweroff(void);
+
 extern int register_restart_handler(struct notifier_block *);
 extern int unregister_restart_handler(struct notifier_block *);
 extern void do_kernel_restart(char *cmd);
diff --git a/kernel/reboot.c b/kernel/reboot.c
index 5925f5a..bdfab65 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -106,6 +106,87 @@ EXPORT_SYMBOL(unregister_reboot_notifier);
 
 /*
  *	Notifier list for kernel code which wants to be called
+ *	to power off the system.
+ */
+static ATOMIC_NOTIFIER_HEAD(poweroff_handler_list);
+
+/**
+ *	register_poweroff_handler - Register function to be called to power off
+ *				    the system
+ *	@nb: Info about handler function to be called
+ *	@nb->priority:	Handler priority. Handlers should follow the
+ *			following guidelines for setting priorities.
+ *			0:	Poweroff handler of last resort,
+ *				with limited poweroff capabilities
+ *			128:	Default poweroff handler; use if no other
+ *				poweroff handler is expected to be available,
+ *				and/or if poweroff functionality is
+ *				sufficient to poweroff the entire system
+ *			255:	Highest priority poweroff handler, will
+ *				preempt all other poweroff handlers
+ *
+ *	Registers a function with code to be called to poweroff the
+ *	system.
+ *
+ *	Registered functions will be called from machine_power_off as last
+ *	step of the poweroff sequence (if the architecture specific
+ *	machine_power_off function calls do_kernel_poweroff - see below
+ *	for details).
+ *	Registered functions are expected to poweroff the system immediately.
+ *	If more than one function is registered, the poweroff handler priority
+ *	selects which function will be called first.
+ *
+ *	Poweroff handlers are expected to be registered from non-architecture
+ *	code, typically from drivers. A typical use case would be a system
+ *	where poweroff functionality is provided through a mfd driver. Multiple
+ *	poweroff handlers may exist; for example, one poweroff handler might
+ *	poweroff the entire system, while another only powers off the CPU.
+ *	In such cases, the poweroff handler which only powers off part of the
+ *	hardware is expected to register with low priority to ensure that
+ *	it only runs if no other means to poweroff the system is available.
+ *
+ *	Currently always returns zero, as atomic_notifier_chain_register()
+ *	always returns zero.
+ */
+int register_poweroff_handler(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&poweroff_handler_list, nb);
+}
+EXPORT_SYMBOL(register_poweroff_handler);
+
+/**
+ *	unregister_poweroff_handler - Unregister previously registered
+ *				      poweroff handler
+ *	@nb: Hook to be unregistered
+ *
+ *	Unregisters a previously registered poweroff handler function.
+ *
+ *	Returns zero on success, or %-ENOENT on failure.
+ */
+int unregister_poweroff_handler(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&poweroff_handler_list, nb);
+}
+EXPORT_SYMBOL(unregister_poweroff_handler);
+
+/**
+ *	do_kernel_poweroff - Execute kernel poweroff handler call chain
+ *
+ *	Calls functions registered with register_poweroff_handler.
+ *
+ *	Expected to be called from machine_poweroff as last step of the poweroff
+ *	sequence.
+ *
+ *	Powers off the system immediately if a poweroff handler function
+ *	has been registered. Otherwise does nothing.
+ */
+void do_kernel_poweroff(void)
+{
+	atomic_notifier_call_chain(&poweroff_handler_list, 0, NULL);
+}
+
+/*
+ *	Notifier list for kernel code which wants to be called
  *	to restart the system.
  */
 static ATOMIC_NOTIFIER_HEAD(restart_handler_list);
-- 
1.9.1

