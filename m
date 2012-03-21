From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 06:56:50 +0000
Subject: [PATCH 09/16] mm/ia64: use vm_flags_t for vma flags
Message-Id: <20120321065650.13852.75898.stgit@zurg>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120321065140.13852.52315.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/mm/fault.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 20b3593..e50259d 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -80,7 +80,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
 	struct siginfo si;
-	unsigned long mask;
+	vm_flags_t mask;
 	int fault;
 
 	/* mmap_sem is performance critical.... */
@@ -135,10 +135,9 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 #	define VM_WRITE_BIT	1
 #	define VM_EXEC_BIT	2
 
-#	if (((1 << VM_READ_BIT) != VM_READ || (1 << VM_WRITE_BIT) != VM_WRITE) \
-	    || (1 << VM_EXEC_BIT) != VM_EXEC)
-#		error File is out of sync with <linux/mm.h>.  Please update.
-#	endif
+	BUILD_BUG_ON((1 << VM_READ_BIT) != VM_READ);
+	BUILD_BUG_ON((1 << VM_WRITE_BIT) != VM_WRITE);
+	BUILD_BUG_ON((1 << VM_EXEC_BIT) != VM_EXEC);
 
 	if (((isr >> IA64_ISR_R_BIT) & 1UL) && (!(vma->vm_flags & (VM_READ | VM_WRITE))))
 		goto bad_area;

