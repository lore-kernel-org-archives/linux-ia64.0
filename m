From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Thu, 31 Jul 2003 04:53:00 +0000
Subject: [PATCH] 2.4.21 Interrupt polarity fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Thu_Jul_31_13:53:00_2003_219)--"
Message-Id: <marc-linux-ia64-105962723421294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

----Next_Part(Thu_Jul_31_13:53:00_2003_219)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi Bjorn,

It seems that acpi_register_intr (in arch/ia64/kernel/acpi.c)
takes an interrupt polarity/trigger in opposite way.
Attached patch fixes this.  Please apply.

drivers/acpi/resource/rsirq.c decodes ACPI extended irq
resource and stores in edge_level and active_high_low members
of a structure (BTW, I think the names of these members
are source of confusion ;).

And this logic in acpi.c inverts both polarity and trigger.

vector = iosapic_register_intr(gsi,
	polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
	mode ? IOSAPIC_EDGE : IOSAPIC_LEVEL);

       ACPI -> rsirq.c -> serial.c -> acpi.c            -> iosapic.c
High      0         0           0      IOSAPIC_POL_LOW
Low       1         1           1      IOSAPIC_POL_HIGH
Edge      1         0           0      IOSAPIC_LEVEL
Level     0         1           1      IOSAPIC_EDGE

As ACPI_ACTIVE_{HIGH,LOW} and ACPI_{LEVEL,EDGE}_SENSITIVE are
defined in acpi subsystem, it should be safer to use these symbols.

---
1st Computer Software Division, NEC Corporation
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp/t-kochi@bq.jp.nec.com>

----Next_Part(Thu_Jul_31_13:53:00_2003_219)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="acpi-int-pol.patch"

--- linux-2.4.21.orig/arch/ia64/kernel/acpi.c	Thu Jul 31 13:14:21 2003
+++ linux-2.4.21/arch/ia64/kernel/acpi.c	Thu Jul 31 13:42:36 2003
@@ -643,8 +643,9 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr(gsi, polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
-			mode ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
+	vector = iosapic_register_intr(gsi,
+		       	(polarity == ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+			(mode == ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return vector;
 }
 

----Next_Part(Thu_Jul_31_13:53:00_2003_219)----
