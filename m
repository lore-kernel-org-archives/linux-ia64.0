From: akpm@linux-foundation.org
Date: Thu, 13 Dec 2007 23:58:27 +0000
Subject: [patch 3/3] ia64: ia32 nopage
Message-Id: <200712132358.lBDNwRqe025179@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Nick Piggin <npiggin@suse.de>

Convert ia64's ia32 support from nopage to fault.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/ia32/binfmt_elf32.c |   34 ++++++++++++++------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff -puN arch/ia64/ia32/binfmt_elf32.c~ia64-ia32-nopage arch/ia64/ia32/binfmt_elf32.c
--- a/arch/ia64/ia32/binfmt_elf32.c~ia64-ia32-nopage
+++ a/arch/ia64/ia32/binfmt_elf32.c
@@ -52,33 +52,29 @@ extern struct page *ia32_shared_page[];
 extern unsigned long *ia32_gdt;
 extern struct page *ia32_gate_page;
 
-struct page *
-ia32_install_shared_page (struct vm_area_struct *vma, unsigned long address, int *type)
+int
+ia32_install_shared_page (struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct page *pg = ia32_shared_page[smp_processor_id()];
-	get_page(pg);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return pg;
-}
-
-struct page *
-ia32_install_gate_page (struct vm_area_struct *vma, unsigned long address, int *type)
-{
-	struct page *pg = ia32_gate_page;
-	get_page(pg);
-	if (type)
-		*type = VM_FAULT_MINOR;
-	return pg;
+	vmf->page = ia32_shared_page[smp_processor_id()];
+	get_page(vmf->page);
+	return 0;
+}
+
+int
+ia32_install_gate_page (struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	vmf->page = ia32_gate_page;
+	get_page(vmf->page);
+	return 0;
 }
 
 
 static struct vm_operations_struct ia32_shared_page_vm_ops = {
-	.nopage = ia32_install_shared_page
+	.fault = ia32_install_shared_page
 };
 
 static struct vm_operations_struct ia32_gate_page_vm_ops = {
-	.nopage = ia32_install_gate_page
+	.fault = ia32_install_gate_page
 };
 
 void
_
