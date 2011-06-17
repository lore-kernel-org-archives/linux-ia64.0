From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 17 Jun 2011 08:45:38 +0000
Subject: [PATCH 04/10] ia64: change xlate_dev_mem_ptr's argument to phys_addr_t
Message-Id: <201106171045.38996.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
In-Reply-To: <201106171038.25988.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

No further changes are needed on ia64, because phys_addr_t is always
64-bit here, hence the same size as an unsigned long.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 arch/ia64/include/asm/uaccess.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 449c8c0..930717e 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -366,7 +366,7 @@ ia64_done_with_exception (struct pt_regs *regs)
 
 #define ARCH_HAS_TRANSLATE_MEM_PTR	1
 static __inline__ char *
-xlate_dev_mem_ptr (unsigned long p)
+xlate_dev_mem_ptr (phys_addr_t p)
 {
 	struct page *page;
 	char * ptr;
-- 
1.7.3.4
