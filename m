From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 08 Oct 2003 23:20:22 +0000
Subject: [PATCH] move find_memory()
Message-Id: <marc-linux-ia64-106565533807870@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that the ACPI table parsing stuff has been fixed we can move
find_memory() back where it belongs--after the SRAT table has been
parsed.

Thanks,
Jesse

diff -Nru a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Mon Sep 29 17:06:17 2003
+++ b/arch/ia64/kernel/setup.c	Mon Sep 29 17:06:17 2003
@@ -239,7 +236,6 @@
 	strlcpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
 
 	efi_init();
-	find_memory();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -253,6 +249,8 @@
 # endif
 #endif /* CONFIG_APCI_BOOT */
 
+	find_memory();
+
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
 
