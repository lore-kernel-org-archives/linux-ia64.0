From: Russ Anderson <rja@sgi.com>
Date: Fri, 03 Jun 2005 21:09:25 +0000
Subject: Re: [PATCH] fix setting of sn_hub_info->shub_1_1_found
Message-Id: <200506032109.j53L9PKP1746761@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
In-Reply-To: <42A04C38.mailxA351PB0RI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >It was my understanding from linux/Documentation/DocBook/kernel-hacking.tmpl
> >that '__initdata' meant that the variable shub_1_1_found was not initialized
> >to anything (unlike ordinary static data).
> 
> I'd never noticed that ... but it does make sense.  I wonder whether there
> are any other __initdata declarations, written by people as clueless as me,
> that are wrong?

Looks like a few in arch/ia64/kernel/acpi.c

Signed-off-by: Russ Anderson (rja@sgi.com)

---------------------------------------------------------
Index: linux-2.6.git/arch/ia64/kernel/acpi.c
=================================--- linux-2.6.git.orig/arch/ia64/kernel/acpi.c	2005-05-16 15:09:02.442863872 -0500
+++ linux-2.6.git/arch/ia64/kernel/acpi.c	2005-06-03 15:57:47.581162358 -0500
@@ -163,8 +163,8 @@
                             Boot-time Table Parsing
    -------------------------------------------------------------------------- */
 
-static int			total_cpus __initdata;
-static int			available_cpus __initdata;
+static int __initdata		total_cpus = 0;
+static int __initdata		available_cpus = 0;
 struct acpi_table_madt *	acpi_madt __initdata;
 static u8			has_8259;
 
@@ -356,7 +356,7 @@
 
 #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
 
-static int __initdata srat_num_cpus;			/* number of cpus */
+static int __initdata srat_num_cpus = 0;		/* number of cpus */
 static u32 __devinitdata pxm_flag[PXM_FLAG_LEN];
 #define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
 #define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
