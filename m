From: Chad Talbott <chadt@sgi.com>
Date: Wed, 18 Jun 2003 22:30:52 +0000
Subject: Re: [PATCH] early_printk for SGI SN2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
Message-Id: <marc-linux-ia64-105597551609147@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597176305635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597176305635@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-=-=

David Mosberger <davidm@napali.hpl.hp.com> writes:

> >>>>> On 18 Jun 2003 15:04:02 -0700, Chad Talbott <chadt@sgi.com> said:
> 
>   Chad> The name may not be the best.  The routines are called sal_*
>   Chad> as they use an SGI specific SAL call to actually output the
>   Chad> text.  Perhaps sn_sal_console_out?
> 
> Sure, that'd work for me.

Agreed.  :)

Here's the changed patch for reference.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=early_printk.diff

diff -Nru a/kernel/printk.c b/kernel/printk.c
--- a/kernel/printk.c	Tue Jun 17 14:47:33 2003
+++ b/kernel/printk.c	Tue Jun 17 14:47:33 2003
@@ -784,6 +784,10 @@
 
 # endif /* CONFIG_IA64_EARLY_PRINTK_UART */
 
+#ifdef CONFIG_IA64_EARLY_PRINTK_SGI_SN
+extern int sn_sal_console_out(const char *str, int len);
+#endif
+
 void early_printk(const char *str, size_t len)
 {
 #ifdef CONFIG_IA64_EARLY_PRINTK_UART
@@ -791,6 +795,9 @@
 #endif
 #ifdef CONFIG_IA64_EARLY_PRINTK_VGA
 	early_printk_vga(str, len);
+#endif
+#ifdef CONFIG_IA64_EARLY_PRINTK_SGI_SN
+ 	sn_sal_console_out(str, len);
 #endif
 }
 
diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Tue Jun 17 14:45:16 2003
+++ b/arch/ia64/Kconfig	Tue Jun 17 14:45:16 2003
@@ -863,6 +831,10 @@
 
 config IA64_EARLY_PRINTK_VGA
 	bool "Early printk on VGA"
+	depends on IA64_EARLY_PRINTK
+
+config IA64_EARLY_PRINTK_SGI_SN
+	bool "Early printk on SGI SN serial console"
 	depends on IA64_EARLY_PRINTK
 
 config DEBUG_SLAB

--=-=-=--
