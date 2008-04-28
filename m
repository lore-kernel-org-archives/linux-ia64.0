From: Al Viro <viro@ftp.linux.org.uk>
Date: Mon, 28 Apr 2008 05:59:15 +0000
Subject: [PATCH] fix ia64 local_irq_save() et.al.
Message-Id: <E1JqMOR-0004le-VO@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, sfr@canb.auug.org.au


psr is not a good name for local variable in macro body when it
has a good chance of being the argument of said macro (actually
is at least in one place)

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/asm-ia64/system.h |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index dff8128..26e250b 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -146,23 +146,23 @@ do {						\
 
 # define local_irq_save(x)					\
 do {								\
-	unsigned long psr;					\
+	unsigned long __psr;					\
 								\
-	__local_irq_save(psr);					\
-	if (psr & IA64_PSR_I)					\
+	__local_irq_save(__psr);				\
+	if (__psr & IA64_PSR_I)					\
 		__save_ip();					\
-	(x) = psr;						\
+	(x) = __psr;						\
 } while (0)
 
-# define local_irq_disable()	do { unsigned long x; local_irq_save(x); } while (0)
+# define local_irq_disable()	do { unsigned long __x; local_irq_save(__x); } while (0)
 
 # define local_irq_restore(x)					\
 do {								\
-	unsigned long old_psr, psr = (x);			\
+	unsigned long __old_psr, __psr = (x);			\
 								\
-	local_save_flags(old_psr);				\
-	__local_irq_restore(psr);				\
-	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I))	\
+	local_save_flags(__old_psr);				\
+	__local_irq_restore(__psr);				\
+	if ((__old_psr & IA64_PSR_I) && !(__psr & IA64_PSR_I))	\
 		__save_ip();					\
 } while (0)
 
-- 
1.5.3.GIT


