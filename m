From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:28:08 +0000
Subject: [PATCH] Fix uninitalised values in ia64_tlb_init
Message-Id: <20050719012808.GE10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix 

arch/ia64/mm/tlb.c: In function 'ia64_tlb_init':
arch/ia64/mm/tlb.c:171: warning: 'ptce_info.base' may be used uninitialized in this function
arch/ia64/mm/tlb.c:171: warning: 'ptce_info.count[0]' may be used uninitialized in this function
arch/ia64/mm/tlb.c:171: warning: 'ptce_info.count[1]' may be used uninitialized in this function
arch/ia64/mm/tlb.c:171: warning: 'ptce_info.stride[0]' may be used uninitialized in this function
arch/ia64/mm/tlb.c:171: warning: 'ptce_info.stride[1]' may be used uninitialized in this function

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -172,6 +172,8 @@ ia64_tlb_init (void)
 	unsigned long tr_pgbits;
 	long status;
 
+	memset(&ptce_info, 0, sizeof(ptce_info));
+
 	if ((status = ia64_pal_vm_page_size(&tr_pgbits, &purge.mask)) != 0) {
 		printk(KERN_ERR "PAL_VM_PAGE_SIZE failed with status=%ld;"
 		       "defaulting to architected purge page-sizes.\n", status);
