From: George Beshers <gbeshers@sgi.com>
Date: Thu, 11 Oct 2007 19:33:55 +0000
Subject: [PATCH] ia64 IOSAPIC bogus error cleanup
Message-Id: <470E7AA3.5020908@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060704000304000309050504"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------060704000304000309050504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Tony suggested a simplification to my original post on lkml,
the result is this patch.




--------------060704000304000309050504
Content-Type: text/x-patch;
 name="MADT2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="MADT2.patch"


On Altix (sn2) machines the "Error parsing MADT" message is
misleading because the lack of IOSAPIC entries is expected.

Since I am sure someone will ask, I have been told that
the chance of this changing anytime soon is close to nil.

Signed-off-by: George Beshers <gbeshers@sgi.com>

---
 acpi.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)
diff -purN linux-2.6.23/arch/ia64/kernel/acpi.c linux-2.6.23.b/arch/ia64/kernel/acpi.c
--- linux-2.6.23/arch/ia64/kernel/acpi.c	2007-10-09 16:31:38.000000000 -0400
+++ linux-2.6.23.b/arch/ia64/kernel/acpi.c	2007-10-10 21:17:15.597545943 -0400
@@ -678,9 +678,11 @@ int __init acpi_boot_init(void)
 	/* I/O APIC */
 
 	if (acpi_table_parse_madt
-	    (ACPI_MADT_TYPE_IO_SAPIC, acpi_parse_iosapic, NR_IOSAPICS) < 1)
-		printk(KERN_ERR PREFIX
-		       "Error parsing MADT - no IOSAPIC entries\n");
+	    (ACPI_MADT_TYPE_IO_SAPIC, acpi_parse_iosapic, NR_IOSAPICS) < 1) {
+		if (!ia64_platform_is("sn2"))
+			printk(KERN_ERR PREFIX
+			       "Error parsing MADT - no IOSAPIC entries\n");
+	}
 
 	/* System-Level Interrupt Routing */
 

--------------060704000304000309050504--
