From: Matthew Wilcox <willy@debian.org>
Date: Fri, 11 Jul 2003 19:02:34 +0000
Subject: [PATCH] acpi_register_irq()
Message-Id: <marc-linux-ia64-105795124411277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


acpi_madt is marked as __initdata, so an attempt to use
acpi_register_irq() after we discarded init sections would cause us to
dereference a random location.  Everywhere else uses has_8259 anyway.

Index: arch/ia64/kernel/acpi.c
=================================RCS file: /var/cvs/linux-2.5/arch/ia64/kernel/acpi.c,v
retrieving revision 1.11
diff -u -p -r1.11 acpi.c
--- arch/ia64/kernel/acpi.c	2 Jul 2003 22:07:32 -0000	1.11
+++ arch/ia64/kernel/acpi.c	11 Jul 2003 18:58:43 -0000
@@ -720,7 +720,7 @@ acpi_register_irq (u32 gsi, u32 polarity
 {
 	int vector = 0;
 
-	if (acpi_madt->flags.pcat_compat && (gsi < 16))
+	if (has_8259 && (gsi < 16))
 		return isa_irq_to_vector(gsi);
 
 	if (!iosapic_register_intr)

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
