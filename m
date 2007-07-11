From: Jes Sorensen <jes@sgi.com>
Date: Wed, 11 Jul 2007 15:26:30 +0000
Subject: [patch] silence GCC ia64 unused variable warnings
Message-Id: <4694F6A6.3080304@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090903050702080705040700"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090903050702080705040700
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

Purely to keep GCC 4+ from spewing out annoying warnings that serve no
purpose.

Cheers,
Jes


--------------090903050702080705040700
Content-Type: text/plain;
 name="kill-ia64-unused-warns.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kill-ia64-unused-warns.diff"

Tell GCC to stop spewing out unncessary warnings for unused variables
passed to functions as pointers for ia64 files.

Signed-off-by: Jes Sorensen <jes@sgi.com>

---
 arch/ia64/kernel/process.c              |    3 ++-
 arch/ia64/mm/tlb.c                      |    2 +-
 arch/ia64/sn/kernel/tiocx.c             |    2 +-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

Index: linux-2.6-lguest/arch/ia64/kernel/process.c
===================================================================
--- linux-2.6-lguest.orig/arch/ia64/kernel/process.c
+++ linux-2.6-lguest/arch/ia64/kernel/process.c
@@ -513,7 +513,8 @@ copy_thread (int nr, unsigned long clone
 static void
 do_copy_task_regs (struct task_struct *task, struct unw_frame_info *info, void *arg)
 {
-	unsigned long mask, sp, nat_bits = 0, ip, ar_rnat, urbs_end, cfm;
+	unsigned long mask, sp, nat_bits = 0, ar_rnat, urbs_end, cfm;
+	unsigned long uninitialized_var(ip);	/* GCC be quiet */
 	elf_greg_t *dst = arg;
 	struct pt_regs *pt;
 	char nat;
Index: linux-2.6-lguest/arch/ia64/mm/tlb.c
===================================================================
--- linux-2.6-lguest.orig/arch/ia64/mm/tlb.c
+++ linux-2.6-lguest/arch/ia64/mm/tlb.c
@@ -175,7 +175,7 @@ EXPORT_SYMBOL(flush_tlb_range);
 void __devinit
 ia64_tlb_init (void)
 {
-	ia64_ptce_info_t ptce_info;
+	ia64_ptce_info_t uninitialized_var(ptce_info); /* GCC be quiet */
 	unsigned long tr_pgbits;
 	long status;
 
Index: linux-2.6-lguest/arch/ia64/sn/kernel/tiocx.c
===================================================================
--- linux-2.6-lguest.orig/arch/ia64/sn/kernel/tiocx.c
+++ linux-2.6-lguest/arch/ia64/sn/kernel/tiocx.c
@@ -369,7 +369,7 @@ static void tio_corelet_reset(nasid_t na
 
 static int is_fpga_tio(int nasid, int *bt)
 {
-	u16 ioboard_type;
+	u16 uninitialized_var(ioboard_type);	/* GCC be quiet */
 	s64 rc;
 
 	rc = ia64_sn_sysctl_ioboard_get(nasid, &ioboard_type);
Index: linux-2.6-lguest/arch/ia64/sn/pci/pcibr/pcibr_provider.c
===================================================================
--- linux-2.6-lguest.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ linux-2.6-lguest/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -80,7 +80,7 @@ static int sal_pcibr_error_interrupt(str
 u16 sn_ioboard_to_pci_bus(struct pci_bus *pci_bus)
 {
 	s64 rc;
-	u16 ioboard;
+	u16 uninitialized_var(ioboard);		/* GCC be quiet */
 	nasid_t nasid = NASID_GET(SN_PCIBUS_BUSSOFT(pci_bus)->bs_base);
 
 	rc = ia64_sn_sysctl_ioboard_get(nasid, &ioboard);

--------------090903050702080705040700--
