From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 03 Mar 2004 19:22:12 +0000
Subject: [PATCH] don't assume iosapic interrupt controllers take 2
Message-Id: <20040303192212.GA3571@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040301224526.GA22182@sgi.com>
In-Reply-To: <20040301224526.GA22182@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some ia64 machines don't use an iosapic interrupt controller (a flagrant
violation of the DIG64 spec, gasp!), so don't assume it's there in
mca.c.  Platforms that provide a ACPI_INTERRUPT_CPEI vector are
responsible for registering its interrupt controller type in platform
specific code, iosapic.c:iosapic_register_platform_intr() does this for
platforms with an iosapic where the CPEI vector is listed in the ACPI
namespace, and on sn2, all external interrupts are assigned the
irq_type_sn type, so this change of assumption should be safe.

Thanks,
Jesse


=== arch/ia64/kernel/mca.c 1.59 vs edited ==--- 1.59/arch/ia64/kernel/mca.c	Thu Feb 12 16:14:34 2004
+++ edited/arch/ia64/kernel/mca.c	Mon Mar  1 14:43:35 2004
@@ -103,8 +103,6 @@
 
 static ia64_mc_info_t		ia64_mc_info;
 
-extern struct hw_interrupt_type	irq_type_iosapic_level;
-
 struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
 
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
@@ -1253,7 +1251,6 @@
 				if (irq_to_vector(irq) = cpev) {
 					desc = irq_descp(irq);
 					desc->status |= IRQ_PER_CPU;
-					desc->handler = &irq_type_iosapic_level;
 					setup_irq(irq, &mca_cpe_irqaction);
 				}
 			ia64_mca_register_cpev(cpev);

----- End forwarded message -----
