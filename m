From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Tue, 05 Aug 2003 02:01:02 +0000
Subject: ia64 acpi.c fix for 2.6.0-test2
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Tue_Aug__5_11:01:02_2003_968)--"
Message-Id: <marc-linux-ia64-106004903231076@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

----Next_Part(Tue_Aug__5_11:01:02_2003_968)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi David,

This is a patch to fix the same problem I sent the other day
for 2.4 tree.

Fortunately, we don't have problem without this patch for 2.6
because ACPI and IOSAPIC interface have the same numbers
(ACPI_ACTIVE_LOW = IOSAPIC_LOW, ACPI_EDGE_SENSITIVE = IOSAPIC_EDGE, etc.)
But it should be converted explicitly.

---
1st Computer Software Division, NEC Corporation
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp/t-kochi@bq.jp.nec.com>


----Next_Part(Tue_Aug__5_11:01:02_2003_968)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="acpi.c-2.6.diff"

Index: dcm-260t2/arch/ia64/kernel/acpi.c
===================================================================
RCS file: /data/cvsroot/lia64-2.5/arch/ia64/kernel/acpi.c,v
retrieving revision 1.1.1.19
diff -u -r1.1.1.19 acpi.c
--- dcm-260t2/arch/ia64/kernel/acpi.c	29 Jul 2003 10:33:17 -0000	1.1.1.19
+++ dcm-260t2/arch/ia64/kernel/acpi.c	1 Aug 2003 06:29:37 -0000
@@ -727,7 +727,9 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr (gsi, polarity, trigger);
+	vector = iosapic_register_intr (gsi,
+			(polarity == ACPI_ACTIVE_LOW) ? IOSAPIC_POL_LOW : IOSAPIC_POL_HIGH,
+			(trigger == ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return vector;
 }
 

----Next_Part(Tue_Aug__5_11:01:02_2003_968)----
