From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 05 Mar 2003 18:33:34 +0000
Subject: [Linux-ia64] poweroff through ACPI does not work on 2.5.60 ia64
Message-Id: <marc-linux-ia64-105590709805974@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Unlike the 2.4.* version that provides poweroff for ia64 through ACPI (power
state S5), 2.5.60 only provides poweroff for i386 platforms through
acpi/sleep.c.
With the following (not so clean :-) patch, I could have it working on=20
2.5.60. Thanks for providing a cleaner one.

Xavier
----------------------------------------------------------------------------
diff --exclude-from /users/xb/proc/diff.exclude -Nur 2.5.60.ref/drivers/acp=
i/Kconfig 2.5.60/drivers/acpi/Kconfig
--- 2.5.60.ref/drivers/acpi/Kconfig	2003-02-10 19:39:14.000000000 +0100
+++ 2.5.60/drivers/acpi/Kconfig	2003-03-05 12:04:42.000000000 +0100
@@ -58,7 +58,7 @@
=20
 config ACPI_SLEEP
 	bool "Sleep States"
-	depends on X86 && ACPI && !ACPI_HT_ONLY && SOFTWARE_SUSPEND
+	depends on IA64 || X86 && ACPI && !ACPI_HT_ONLY && SOFTWARE_SUSPEND
 	---help---
 	  This option adds support for ACPI suspend states.=20
=20
diff --exclude-from /users/xb/proc/diff.exclude -Nur 2.5.60.ref/drivers/acp=
i/sleep.c 2.5.60/drivers/acpi/sleep.c
--- 2.5.60.ref/drivers/acpi/sleep.c	2003-02-10 19:37:56.000000000 +0100
+++ 2.5.60/drivers/acpi/sleep.c	2003-03-05 19:55:00.000000000 +0100
@@ -34,10 +34,12 @@
 #define ACPI_SYSTEM_FILE_SLEEP		"sleep"
 #define ACPI_SYSTEM_FILE_ALARM		"alarm"
=20
+static u8 sleep_states[ACPI_S_STATE_COUNT];
+
+#ifdef CONFIG_X86
 static int acpi_system_sleep_open_fs(struct inode *inode, struct file *fil=
e);
 static int acpi_system_alarm_open_fs(struct inode *inode, struct file *fil=
e);
=20
-static u8 sleep_states[ACPI_S_STATE_COUNT];
=20
 static struct file_operations acpi_system_sleep_fops =3D {
 	.open		=3D acpi_system_sleep_open_fs,
@@ -52,6 +54,7 @@
 	.llseek		=3D seq_lseek,
 	.release	=3D single_release,
 };
+#endif /* CONFIG_X86 */
=20
 static void
 acpi_power_off (void)
@@ -61,6 +64,8 @@
 	acpi_enter_sleep_state(ACPI_STATE_S5);
 }
=20
+#ifdef CONFIG_X86
+
 /**
  * acpi_system_restore_state - OS-specific restoration of state
  * @state:	sleep state we're exiting
@@ -97,7 +102,6 @@
 		printk("Broken toshiba laptop -> kicking interrupts\n");
 		init_8259A(0);
 	}
-
 	return AE_OK;
 }
=20
@@ -624,7 +628,7 @@
 end:
 	return_VALUE(result ? result : count);
 }
-
+#endif /* CONFIG_X86 */
=20
 #if defined(CONFIG_MAGIC_SYSRQ) && defined(CONFIG_PM)
=20
@@ -665,7 +669,7 @@
 	}
 	printk(")\n");
=20
-
+#ifdef CONFIG_X86
 	/* 'sleep' [R/W]*/
 	entry =3D create_proc_entry(ACPI_SYSTEM_FILE_SLEEP,
 		S_IFREG|S_IRUGO|S_IWUSR, acpi_root_dir);
@@ -689,6 +693,7 @@
 		entry->proc_fops =3D &acpi_system_alarm_fops;
 		entry->proc_fops->write =3D acpi_system_write_alarm;
 	}
+#endif /* CONFIG_X86 */
=20
 	/* Install the soft-off (S5) handler. */
 	if (sleep_states[ACPI_STATE_S5]) {

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________

