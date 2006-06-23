From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 23 Jun 2006 20:45:25 +0000
Subject: [PATCH] missed ia64 fadt_descriptor_rev2 reference
Message-Id: <20060623204525.GA29658@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

I've hit a compile error in current git due to a missed
fadt_descriptor_rev2 -> fadt_descriptor conversion in
arch/ia64/kernel/acpi.c:

  CC      arch/ia64/kernel/acpi.o
arch/ia64/kernel/acpi.c: In function ‘acpi_parse_fadt’:
arch/ia64/kernel/acpi.c:632: error: dereferencing pointer to incomplete type
arch/ia64/kernel/acpi.c:635: error: dereferencing pointer to incomplete type
arch/ia64/kernel/acpi.c:638: error: dereferencing pointer to incomplete type
make[1]: *** [arch/ia64/kernel/acpi.o] Error 1
make: *** [arch/ia64/kernel] Error 2

that came in with this changeset:

http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;hy3c2388cae3fd023b3b5166354931752d42353c

Signed-off-by: Greg Edwards <edwardsg@sgi.com>

---
 arch/ia64/kernel/acpi.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: git-linus/arch/ia64/kernel/acpi.c
=================================--- git-linus.orig/arch/ia64/kernel/acpi.c	2006-06-23 13:58:59.000000000 -0500
+++ git-linus/arch/ia64/kernel/acpi.c	2006-06-23 15:21:41.588064728 -0500
@@ -618,7 +618,7 @@ EXPORT_SYMBOL(acpi_unregister_gsi);
 static int __init acpi_parse_fadt(unsigned long phys_addr, unsigned long size)
 {
 	struct acpi_table_header *fadt_header;
-	struct fadt_descriptor_rev2 *fadt;
+	struct fadt_descriptor *fadt;
 
 	if (!phys_addr || !size)
 		return -EINVAL;
@@ -627,7 +627,7 @@ static int __init acpi_parse_fadt(unsign
 	if (fadt_header->revision != 3)
 		return -ENODEV;	/* Only deal with ACPI 2.0 FADT */
 
-	fadt = (struct fadt_descriptor_rev2 *)fadt_header;
+	fadt = (struct fadt_descriptor *)fadt_header;
 
 	if (!(fadt->iapc_boot_arch & BAF_8042_KEYBOARD_CONTROLLER))
 		acpi_kbd_controller_present = 0;
