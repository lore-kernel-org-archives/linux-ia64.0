From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 14 Mar 2005 19:28:01 +0000
Subject: [PATCH] remove redundant irq_affinity definition
Message-Id: <200503141128.01855.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_BXeNC3ZdRjXFjPP"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_BXeNC3ZdRjXFjPP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

gcc4 complains about multiple definitions of irq_affinity--I think the one in 
arch/ia64/kernel/irq.c is the redundant one since the array is also defined 
in kernel/irq/manage.c.

Building with gcc4 generates a bunch of warnings too, saying that qualifiers 
on function return types are being ignored (in particular the ones from 
__ia64_get_io_port_base and the ones having to do with mmu_context_t being 
volatile).  Should we use attribute(const) for get_io_port_base?  What about 
for the mmu_context_t functions?

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_BXeNC3ZdRjXFjPP
Content-Type: text/plain;
  charset="us-ascii";
  name="generic-irqs-ia64-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="generic-irqs-ia64-fix.patch"

===== arch/ia64/kernel/irq.c 1.55 vs edited =====
--- 1.55/arch/ia64/kernel/irq.c	2005-01-22 15:54:25 -08:00
+++ edited/arch/ia64/kernel/irq.c	2005-03-14 11:24:20 -08:00
@@ -97,7 +97,6 @@
 cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
 static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
 
-static cpumask_t irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
 static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
 
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)

--Boundary-00=_BXeNC3ZdRjXFjPP--
