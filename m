From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 05 Aug 2003 22:16:07 +0000
Subject: Re: [PATCH] 2.4.21 Interrupt polarity fix
Message-Id: <marc-linux-ia64-106012193812192@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105962723421294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105962723421294@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 30 July 2003 10:53 pm, Takayoshi Kochi wrote:
> It seems that acpi_register_intr (in arch/ia64/kernel/acpi.c)
> takes an interrupt polarity/trigger in opposite way.
> Attached patch fixes this.  Please apply.

Thanks.  This was indeed very confusing.  I applied the
following patch for 2.4.  The corresponding patch you
posted on August 4 for 2.6 appears functionally identical
but reverses the sense of the polarity test for no good
reason.  Can you send David a revised patch that does
it the same was as the one below?

Bjorn

#### AUTHOR kochi@hpc.bs1.fc.nec.co.jp
#### COMMENT START
### Comments for ChangeSet
ia64: Fix ACPI interrupt polarity/trigger interpretation

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
### Comments for arch/ia64/kernel/acpi.c
Fix ACPI interrupt polarity/trigger interpretation
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1060  -> 1.1061 
#	arch/ia64/kernel/acpi.c	1.16    -> 1.17   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/05	bjorn.helgaas@hp.com	1.1061
# find intrs
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Tue Aug  5 17:00:35 2003
+++ b/arch/ia64/kernel/acpi.c	Tue Aug  5 17:00:35 2003
@@ -643,8 +643,9 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr(gsi, polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
-			mode ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
+	vector = iosapic_register_intr(gsi,
+		       	(polarity = ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+			(mode = ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return vector;
 }
 

