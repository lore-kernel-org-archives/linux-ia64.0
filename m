From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 May 2006 21:16:28 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200605172116.k4HLGSqg008551@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/sn2_defconfig |    4 ++--
 arch/ia64/kernel/iosapic.c      |    4 ++--
 arch/ia64/kernel/irq.c          |    1 -
 3 files changed, 4 insertions(+), 5 deletions(-)

Chen, Kenneth W:
      [IA64] fix broken irq affinity
      [IA64] one-line cleanup on set_irq_affinity_info

Jes Sorensen:
      [IA64] sn2 defconfig

diff-tree 4c31ce8fea9760961a2d1b1d6c84b7590c17ae38 (from 41503def5d83bada6a2fd792e636ccc28a285f38)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Tue May 16 16:34:57 2006 -0700

    [IA64] one-line cleanup on set_irq_affinity_info
    
    Calls to set_irq_info in set_irq_affinity_info() is redundant because
    irq_affinity mask was set just one line immediately above it.  Remove
    that duplicate call.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index 5ce908e..9c72ea3 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -101,7 +101,6 @@ void set_irq_affinity_info (unsigned int
 
 	if (irq < NR_IRQS) {
 		irq_affinity[irq] = mask;
-		set_irq_info(irq, mask);
 		irq_redir[irq] = (char) (redir & 0xff);
 	}
 }

diff-tree 41503def5d83bada6a2fd792e636ccc28a285f38 (from 1101ece44e00cfe31a2fd9d3222d05f927b00ef8)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Tue May 16 16:29:00 2006 -0700

    [IA64] fix broken irq affinity
    
    When CONFIG_PCI_MSI is set, move_irq() is an empty function, causing
    grief when sys admin tries to bind interrupt to CPU.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 7956eb9..d58c1c5 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -416,7 +416,7 @@ iosapic_end_level_irq (unsigned int irq)
 	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;
 
-	move_irq(irq);
+	move_native_irq(irq);
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
 		iosapic_eoi(rte->addr, vec);
 }
@@ -458,7 +458,7 @@ iosapic_ack_edge_irq (unsigned int irq)
 {
 	irq_desc_t *idesc = irq_descp(irq);
 
-	move_irq(irq);
+	move_native_irq(irq);
 	/*
 	 * Once we have recorded IRQ_PENDING already, we can mask the
 	 * interrupt for real. This prevents IRQ storms from unhandled

diff-tree 1101ece44e00cfe31a2fd9d3222d05f927b00ef8 (from c4694c76ce28dd7e415b4f3014d8c6e580b5f3d2)
Author: Jes Sorensen <jes@sgi.com>
Date:   Mon May 15 05:07:54 2006 -0400

    [IA64] sn2 defconfig
    
    Set node shift to 10 on SN2 and disable mutex debugging.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index f6a8853..9ea3539 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -134,7 +134,7 @@ CONFIG_ARCH_FLATMEM_ENABLE=y
 CONFIG_ARCH_SPARSEMEM_ENABLE=y
 CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
 CONFIG_NUMA=y
-CONFIG_NODES_SHIFT=8
+CONFIG_NODES_SHIFT
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
 CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y
@@ -1159,7 +1159,7 @@ CONFIG_DETECT_SOFTLOCKUP=y
 # CONFIG_SCHEDSTATS is not set
 # CONFIG_DEBUG_SLAB is not set
 CONFIG_DEBUG_PREEMPT=y
-CONFIG_DEBUG_MUTEXES=y
+# CONFIG_DEBUG_MUTEXES is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
 # CONFIG_DEBUG_KOBJECT is not set
