From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Date: Fri, 23 Feb 2018 16:58:47 +0000
Subject: [PATCH 1/3] ftrace: Add module to ftrace_make_call() parameters
Message-Id: <20180223165849.16388-2-alexander.sverdlin@nokia.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
In-Reply-To: <20180223165849.16388-1-alexander.sverdlin@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

ARM support for modules' PLTs will require a module pointer in
ftrace_make_call() exactly as ftrace_make_nop() has it. Change the function
signature without functional change for now.

Signed-off-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
---
 arch/arm/kernel/ftrace.c           | 3 ++-
 arch/arm64/kernel/ftrace.c         | 3 ++-
 arch/blackfin/kernel/ftrace.c      | 3 ++-
 arch/ia64/kernel/ftrace.c          | 3 ++-
 arch/metag/kernel/ftrace.c         | 3 ++-
 arch/microblaze/kernel/ftrace.c    | 3 ++-
 arch/mips/kernel/ftrace.c          | 3 ++-
 arch/powerpc/kernel/trace/ftrace.c | 3 ++-
 arch/s390/kernel/ftrace.c          | 3 ++-
 arch/sh/kernel/ftrace.c            | 3 ++-
 arch/sparc/kernel/ftrace.c         | 3 ++-
 arch/tile/kernel/ftrace.c          | 3 ++-
 arch/x86/kernel/ftrace.c           | 3 ++-
 include/linux/ftrace.h             | 4 +++-
 kernel/trace/ftrace.c              | 6 +++---
 15 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/arch/arm/kernel/ftrace.c b/arch/arm/kernel/ftrace.c
index 5617932..be20adc 100644
--- a/arch/arm/kernel/ftrace.c
+++ b/arch/arm/kernel/ftrace.c
@@ -162,7 +162,8 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	return ret;
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long new, old;
 	unsigned long ip = rec->ip;
diff --git a/arch/arm64/kernel/ftrace.c b/arch/arm64/kernel/ftrace.c
index 50986e3..e3a95d3 100644
--- a/arch/arm64/kernel/ftrace.c
+++ b/arch/arm64/kernel/ftrace.c
@@ -68,7 +68,8 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 /*
  * Turn on the call to ftrace_caller() in instrumented function
  */
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long pc = rec->ip;
 	u32 old, new;
diff --git a/arch/blackfin/kernel/ftrace.c b/arch/blackfin/kernel/ftrace.c
index 8dad758..61ffc99 100644
--- a/arch/blackfin/kernel/ftrace.c
+++ b/arch/blackfin/kernel/ftrace.c
@@ -45,7 +45,8 @@ int ftrace_make_nop(struct module *mod, struct dyn_ftrace *rec,
 	return ftrace_modify_code(rec->ip, mnop, sizeof(mnop));
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	/* Restore the mcount call site */
 	unsigned char call[8];
diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
index cee411e..658a011 100644
--- a/arch/ia64/kernel/ftrace.c
+++ b/arch/ia64/kernel/ftrace.c
@@ -169,7 +169,8 @@ int ftrace_make_nop(struct module *mod,
 	return ftrace_modify_code(rec->ip, NULL, new, 0);
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long ip = rec->ip;
 	unsigned char *old, *new;
diff --git a/arch/metag/kernel/ftrace.c b/arch/metag/kernel/ftrace.c
index f7b23d3..635652a 100644
--- a/arch/metag/kernel/ftrace.c
+++ b/arch/metag/kernel/ftrace.c
@@ -104,7 +104,8 @@ int ftrace_make_nop(struct module *mod,
 	return ftrace_modify_code(ip, old, new);
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned char *new, *old;
 	unsigned long ip = rec->ip;
diff --git a/arch/microblaze/kernel/ftrace.c b/arch/microblaze/kernel/ftrace.c
index d57563c..01b314a 100644
--- a/arch/microblaze/kernel/ftrace.c
+++ b/arch/microblaze/kernel/ftrace.c
@@ -161,7 +161,8 @@ int ftrace_make_nop(struct module *mod,
 }
 
 /* I believe that first is called ftrace_make_nop before this function */
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	int ret;
 	pr_debug("%s: addr:0x%x, rec->ip: 0x%x, imm:0x%x\n",
diff --git a/arch/mips/kernel/ftrace.c b/arch/mips/kernel/ftrace.c
index 7f3dfdb..9dcec19 100644
--- a/arch/mips/kernel/ftrace.c
+++ b/arch/mips/kernel/ftrace.c
@@ -200,7 +200,8 @@ int ftrace_make_nop(struct module *mod,
 #endif
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned int new;
 	unsigned long ip = rec->ip;
diff --git a/arch/powerpc/kernel/trace/ftrace.c b/arch/powerpc/kernel/trace/ftrace.c
index 4741fe1..b198433 100644
--- a/arch/powerpc/kernel/trace/ftrace.c
+++ b/arch/powerpc/kernel/trace/ftrace.c
@@ -437,7 +437,8 @@ __ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
 #endif /* CONFIG_PPC64 */
 #endif /* CONFIG_MODULES */
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long ip = rec->ip;
 	unsigned int old, new;
diff --git a/arch/s390/kernel/ftrace.c b/arch/s390/kernel/ftrace.c
index dc76d81..1691d53 100644
--- a/arch/s390/kernel/ftrace.c
+++ b/arch/s390/kernel/ftrace.c
@@ -136,7 +136,8 @@ int ftrace_make_nop(struct module *mod, struct dyn_ftrace *rec,
 	return 0;
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	struct ftrace_insn orig, new, old;
 
diff --git a/arch/sh/kernel/ftrace.c b/arch/sh/kernel/ftrace.c
index 96dd9f7..2d3cacd 100644
--- a/arch/sh/kernel/ftrace.c
+++ b/arch/sh/kernel/ftrace.c
@@ -242,7 +242,8 @@ int ftrace_make_nop(struct module *mod,
 	return ftrace_modify_code(rec->ip, old, new);
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned char *new, *old;
 	unsigned long ip = rec->ip;
diff --git a/arch/sparc/kernel/ftrace.c b/arch/sparc/kernel/ftrace.c
index 915dda4..36117b5 100644
--- a/arch/sparc/kernel/ftrace.c
+++ b/arch/sparc/kernel/ftrace.c
@@ -63,7 +63,8 @@ int ftrace_make_nop(struct module *mod, struct dyn_ftrace *rec, unsigned long ad
 	return ftrace_modify_code(ip, old, new);
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long ip = rec->ip;
 	u32 old, new;
diff --git a/arch/tile/kernel/ftrace.c b/arch/tile/kernel/ftrace.c
index b827a41..749e50f 100644
--- a/arch/tile/kernel/ftrace.c
+++ b/arch/tile/kernel/ftrace.c
@@ -136,7 +136,8 @@ int ftrace_update_ftrace_func(ftrace_func_t func)
 	return ret;
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned long new, old;
 	unsigned long ip = rec->ip;
diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 01ebcb6..389f15c 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -162,7 +162,8 @@ int ftrace_make_nop(struct module *mod,
 	return -EINVAL;
 }
 
-int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+		     unsigned long addr)
 {
 	unsigned const char *new, *old;
 	unsigned long ip = rec->ip;
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 9c3c9a3..1e8c421 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -536,6 +536,7 @@ extern int ftrace_make_nop(struct module *mod,
 
 /**
  * ftrace_make_call - convert a nop call site into a call to addr
+ * @mod: module structure if called by module load initialization
  * @rec: the mcount call site record
  * @addr: the address that the call site should call
  *
@@ -554,7 +555,8 @@ extern int ftrace_make_nop(struct module *mod,
  *  -EPERM  on error writing to the location
  * Any other value will be considered a failure.
  */
-extern int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr);
+extern int ftrace_make_call(struct module *mod, struct dyn_ftrace *rec,
+			    unsigned long addr);
 
 #ifdef CONFIG_DYNAMIC_FTRACE_WITH_REGS
 /**
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index eac9ce2..d32f2f5 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -2421,7 +2421,7 @@ unsigned long ftrace_get_addr_curr(struct dyn_ftrace *rec)
 }
 
 static int
-__ftrace_replace_code(struct dyn_ftrace *rec, int enable)
+__ftrace_replace_code(struct module *mod, struct dyn_ftrace *rec, int enable)
 {
 	unsigned long ftrace_old_addr;
 	unsigned long ftrace_addr;
@@ -2442,7 +2442,7 @@ __ftrace_replace_code(struct dyn_ftrace *rec, int enable)
 
 	case FTRACE_UPDATE_MAKE_CALL:
 		ftrace_bug_type = FTRACE_BUG_CALL;
-		return ftrace_make_call(rec, ftrace_addr);
+		return ftrace_make_call(mod, rec, ftrace_addr);
 
 	case FTRACE_UPDATE_MAKE_NOP:
 		ftrace_bug_type = FTRACE_BUG_NOP;
@@ -2470,7 +2470,7 @@ void __weak ftrace_replace_code(int enable)
 		if (rec->flags & FTRACE_FL_DISABLED)
 			continue;
 
-		failed = __ftrace_replace_code(rec, enable);
+		failed = __ftrace_replace_code(NULL, rec, enable);
 		if (failed) {
 			ftrace_bug(failed, rec);
 			/* Stop processing */
-- 
2.4.6

