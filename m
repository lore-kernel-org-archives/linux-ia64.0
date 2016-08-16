From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 16 Aug 2016 15:14:42 +0000
Subject: [PATCH 1/2] ia64: macro-ize ia64_done_with_exception in asm/uaccess.h
Message-Id: <20160816151443.31082-2-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160816151443.31082-1-paul.gortmaker@windriver.com>
In-Reply-To: <20160816151443.31082-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Most of the other C content in this file is already implemented
in macro form.  Doing the same for this function will allow us
to get rid of the duplicated search_exception_tables prototype.
We will bring it in as required via <linux/extable.h> inclusion.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/ia64/include/asm/uaccess.h | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 465c70982f40..4b52b79213a3 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -363,17 +363,17 @@ struct exception_table_entry {
 extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
 extern const struct exception_table_entry *search_exception_tables (unsigned long addr);
 
-static inline int
-ia64_done_with_exception (struct pt_regs *regs)
-{
-	const struct exception_table_entry *e;
-	e = search_exception_tables(regs->cr_iip + ia64_psr(regs)->ri);
-	if (e) {
-		ia64_handle_exception(regs, e);
-		return 1;
-	}
-	return 0;
-}
+#define ia64_done_with_exception(regs)					  \
+({									  \
+	int __ex_ret = 0;						  \
+	const struct exception_table_entry *e;				  \
+	e = search_exception_tables((regs)->cr_iip + ia64_psr(regs)->ri); \
+	if (e) {							  \
+		ia64_handle_exception(regs, e);				  \
+		__ex_ret = 1;						  \
+	}								  \
+	__ex_ret;							  \
+})
 
 #define ARCH_HAS_TRANSLATE_MEM_PTR	1
 static __inline__ void *
-- 
2.8.4

