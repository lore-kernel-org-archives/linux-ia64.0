From: Joe Perches <joe@perches.com>
Date: Tue, 20 Nov 2007 01:47:53 +0000
Subject: [PATCH 01/59] arch/ia64: Add missing "space"
Message-Id: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: 1234567
In-Reply-To: 1234567
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/kprobes.c      |   10 +++++-----
 arch/ia64/mm/tlb.c              |    2 +-
 arch/ia64/sn/kernel/io_common.c |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
index 5fd65d8..90518e4 100644
--- a/arch/ia64/kernel/kprobes.c
+++ b/arch/ia64/kernel/kprobes.c
@@ -182,8 +182,8 @@ static int __kprobes unsupported_inst(uint template, uint  slot,
 	qp = kprobe_inst & 0x3f;
 	if (is_cmp_ctype_unc_inst(template, slot, major_opcode, kprobe_inst)) {
 		if (slot = 1 && qp)  {
-			printk(KERN_WARNING "Kprobes on cmp unc"
-					"instruction on slot 1 at <0x%lx>"
+			printk(KERN_WARNING "Kprobes on cmp unc "
+					"instruction on slot 1 at <0x%lx> "
 					"is not supported\n", addr);
 			return -EINVAL;
 
@@ -221,8 +221,8 @@ static int __kprobes unsupported_inst(uint template, uint  slot,
 			 * bit 12 to be equal to 1
 			 */
 			if (slot = 1 && qp) {
-				printk(KERN_WARNING "Kprobes on test bit"
-						"instruction on slot at <0x%lx>"
+				printk(KERN_WARNING "Kprobes on test bit "
+						"instruction on slot at <0x%lx> "
 						"is not supported\n", addr);
 				return -EINVAL;
 			}
@@ -242,7 +242,7 @@ static int __kprobes unsupported_inst(uint template, uint  slot,
 			 */
 			int x6=(kprobe_inst >> 27) & 0x3F;
 			if ((x6 = 0x10) || (x6 = 0x11)) {
-				printk(KERN_WARNING "Kprobes on"
+				printk(KERN_WARNING "Kprobes on "
 					"Indirect Predict is not supported\n");
 				return -EINVAL;
 			}
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 1682fc6..cef1647 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -180,7 +180,7 @@ ia64_tlb_init (void)
 	long status;
 
 	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
-		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
+		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld; "
 		       "defaulting to architected purge page-sizes.\n", status);
 		purge.mask = 0x115557000UL;
 	}
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 4594770..710bf51 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -347,7 +347,7 @@ sn_common_bus_fixup(struct pci_bus *bus,
 	if (controller->node >= num_online_nodes()) {
 		struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
 
-		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%u"
+		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%u "
 		       "L_IO=%lx L_MEM=%lx BASE=%lx\n",
 		       b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
 		       b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
-- 
1.5.3.5.652.gf192c

