From: Alex Williamson <alex_williamson@hp.com>
Date: Thu, 07 Aug 2003 21:14:25 +0000
Subject: [PATCH] Check for X__DSDT in acpi_get_table_header_early()
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------40D24DD113FB2909FB6880A3"
Message-Id: <marc-linux-ia64-106029096013649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------40D24DD113FB2909FB6880A3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   I finally got tired of my rx2600 printing garbage at the end of
the list of ACPI tables so I decided to fix it.  Turns out the HP
rx2600 does not provide a DSDT in the FADT, so we were trying to
print a table at 0x0.  It does provide a X_DSDT.  This patch will
make acpi_get_table_header_early() prefer the X_DSDT over the DSDT
and adds more checking for null.  Looks like the same code is in
2.6 and 2.4, please apply for both.  Thanks,

	Alex
 
-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------40D24DD113FB2909FB6880A3
Content-Type: text/plain; charset=us-ascii;
 name="xdsdt.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xdsdt.diff"

--- linux/drivers/acpi/tables.c	2003-07-27 11:00:40.000000000 -0600
+++ linux/drivers/acpi/tables.c	2003-08-07 14:15:11.000000000 -0600
@@ -256,10 +256,17 @@
 
 	/* Map the DSDT header via the pointer in the FADT */
 	if (id == ACPI_DSDT) {
-		struct acpi_table_fadt *fadt = (struct acpi_table_fadt *) *header;
+		struct fadt_descriptor_rev2 *fadt = (struct fadt_descriptor_rev2 *) *header;
+
+		if (fadt->header.revision == 3 && fadt->Xdsdt) {
+			*header = (void *) __acpi_map_table(fadt->Xdsdt,
+					sizeof(struct acpi_table_header));
+		} else if (fadt->V1_dsdt) {
+			*header = (void *) __acpi_map_table(fadt->V1_dsdt,
+					sizeof(struct acpi_table_header));
+		} else
+			*header = 0;
 
-		*header = (void *) __acpi_map_table(fadt->dsdt_addr,
-				sizeof(struct acpi_table_header));
 		if (!*header) {
 			printk(KERN_WARNING PREFIX "Unable to map DSDT\n");
 			return -ENODEV;

--------------40D24DD113FB2909FB6880A3--

