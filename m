From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Wed, 06 Aug 2003 01:22:42 +0000
Subject: Re: [PATCH] 2.4.21 Interrupt polarity fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Wed_Aug__6_10:22:42_2003_795)--"
Message-Id: <marc-linux-ia64-106013308221730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105962723421294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105962723421294@msgid-missing>
To: linux-ia64@vger.kernel.org

----Next_Part(Wed_Aug__6_10:22:42_2003_795)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH] 2.4.21 Interrupt polarity fix
Date: Tue, 5 Aug 2003 16:16:07 -0600

> On Wednesday 30 July 2003 10:53 pm, Takayoshi Kochi wrote:
> > It seems that acpi_register_intr (in arch/ia64/kernel/acpi.c)
> > takes an interrupt polarity/trigger in opposite way.
> > Attached patch fixes this.  Please apply.
> 
> Thanks.  This was indeed very confusing.  I applied the
> following patch for 2.4.  The corresponding patch you
> posted on August 4 for 2.6 appears functionally identical
> but reverses the sense of the polarity test for no good
> reason.  Can you send David a revised patch that does
> it the same was as the one below?

Thanks for the comment.  The revised patch is attached.

---
1st Computer Software Division, NEC Corporation
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp/t-kochi@bq.jp.nec.com>

----Next_Part(Wed_Aug__6_10:22:42_2003_795)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ia64-acpi.c.2.diff"

Index: dcm-260t2/arch/ia64/kernel/acpi.c
===================================================================
RCS file: /data/cvsroot/lia64-2.5/arch/ia64/kernel/acpi.c,v
retrieving revision 1.1.1.19
diff -u -r1.1.1.19 acpi.c
--- dcm-260t2/arch/ia64/kernel/acpi.c	29 Jul 2003 10:33:17 -0000	1.1.1.19
+++ dcm-260t2/arch/ia64/kernel/acpi.c	6 Aug 2003 01:19:11 -0000
@@ -727,7 +727,9 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr (gsi, polarity, trigger);
+	vector = iosapic_register_intr (gsi,
+			(polarity == ACPI_ACTIVE_HIGH) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+			(trigger == ACPI_EDGE_SENSITIVE) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return vector;
 }
 

----Next_Part(Wed_Aug__6_10:22:42_2003_795)----
