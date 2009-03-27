From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 27 Mar 2009 06:11:57 +0000
Subject: [PATCH] ia64: remove some warnings.
Message-Id: <20090327061157.GK13054%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch removes the following warnings and related ones.
Plus some cosmetics.

arch/ia64/kernel/patch.c:112: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
arch/ia64/kernel/patch.c:135: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
arch/ia64/kernel/patch.c:166: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
arch/ia64/kernel/patch.c:202: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast
arch/ia64/kernel/patch.c:220: warning: passing argument 1 of 'paravirt_fc' makes integer from pointer without a cast

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/paravirt_privop.h |   22 +++++++++++++++++++---
 arch/ia64/include/asm/xen/privop.h      |    2 +-
 arch/ia64/kernel/paravirt.c             |   22 +++++++++++++++++-----
 arch/ia64/kernel/patch.c                |    2 +-
 arch/ia64/kvm/kvm-ia64.c                |    2 +-
 arch/ia64/kvm/vcpu.c                    |    2 +-
 arch/ia64/xen/xen_pv_ops.c              |    9 +++++++--
 7 files changed, 47 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/include/asm/paravirt_privop.h b/arch/ia64/include/asm/paravirt_privop.h
index 4e40e62..3d29511 100644
--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -33,7 +33,7 @@
  */
 
 struct pv_cpu_ops {
-	void (*fc)(unsigned long addr);
+	void (*fc)(void *addr);
 	unsigned long (*thash)(unsigned long addr);
 	unsigned long (*get_cpuid)(int index);
 	unsigned long (*get_pmd)(int index);
@@ -248,7 +248,7 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 		"r15", "r16", "r17"
 
 #define PARAVIRT_REG_CLOBBERS1					\
-	"r2","r3", /*"r8",*/ "r9", "r10", "r11", "r14",	\
+	"r2","r3", /*"r8",*/ "r9", "r10", "r11", "r14",		\
 		"r15", "r16", "r17"
 
 #define PARAVIRT_REG_CLOBBERS2					\
@@ -330,6 +330,15 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 		      : PARAVIRT_OP(op), "0"(__##arg1)		\
 		      : PARAVIRT_CLOBBERS1)
 
+#define PARAVIRT_BR1_VOID(op, type, arg1)			\
+	register void *__##arg1 asm ("r8") = arg1;		\
+	register unsigned long ia64_clobber asm ("r8");		\
+	asm volatile (paravirt_alt_bundle(__PARAVIRT_BR,	\
+					  PARAVIRT_TYPE(type))	\
+		      :	"=r"(ia64_clobber)			\
+		      : PARAVIRT_OP(op), "0"(__##arg1)		\
+		      : PARAVIRT_CLOBBERS1)
+
 #define PARAVIRT_BR2(op, type, arg1, arg2)				\
 	register unsigned long __##arg1 asm ("r8") = arg1;		\
 	register unsigned long __##arg2 asm ("r9") = arg2;		\
@@ -357,6 +366,13 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 		return ia64_intri_res;			\
 	}
 
+#define PARAVIRT_DEFINE_CPU_OP1_VOID(op, type)		\
+	static inline void				\
+	paravirt_ ## op (void *arg1)			\
+	{						\
+		PARAVIRT_BR1_VOID(op, type, arg1);	\
+	}
+
 #define PARAVIRT_DEFINE_CPU_OP1(op, type)		\
 	static inline void				\
 	paravirt_ ## op (unsigned long arg1)		\
@@ -381,7 +397,7 @@ void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
 	}
 
 
-PARAVIRT_DEFINE_CPU_OP1(fc, FC);
+PARAVIRT_DEFINE_CPU_OP1_VOID(fc, FC);
 PARAVIRT_DEFINE_CPU_OP1_RET(thash, THASH)
 PARAVIRT_DEFINE_CPU_OP1_RET(get_cpuid, GET_CPUID)
 PARAVIRT_DEFINE_CPU_OP1_RET(get_pmd, GET_PMD)
diff --git a/arch/ia64/include/asm/xen/privop.h b/arch/ia64/include/asm/xen/privop.h
index e5fbaee..fb4ec5e 100644
--- a/arch/ia64/include/asm/xen/privop.h
+++ b/arch/ia64/include/asm/xen/privop.h
@@ -69,7 +69,7 @@
  *  may have different semantics depending on whether they are executed
  *  at PL0 vs PL!=0.  When paravirtualized, these instructions mustn't
  *  be allowed to execute directly, lest incorrect semantics result. */
-extern void xen_fc(unsigned long addr);
+extern void xen_fc(void *addr);
 extern unsigned long xen_thash(unsigned long addr);
 
 /* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 158d524..a21d7bb 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -70,7 +70,14 @@ struct pv_init_ops pv_init_ops  	ia64_native_ ## name ## _func(unsigned long arg)	\
 	{							\
 		ia64_native_ ## name(arg);			\
-	}							\
+	}
+
+#define DEFINE_VOID_FUNC1_VOID(name)				\
+	static void						\
+	ia64_native_ ## name ## _func(void *arg)		\
+	{							\
+		ia64_native_ ## name(arg);			\
+	}
 
 #define DEFINE_VOID_FUNC2(name)					\
 	static void						\
@@ -78,7 +85,7 @@ struct pv_init_ops pv_init_ops  				      unsigned long arg1)	\
 	{							\
 		ia64_native_ ## name(arg0, arg1);		\
-	}							\
+	}
 
 #define DEFINE_FUNC0(name)			\
 	static unsigned long			\
@@ -94,7 +101,7 @@ struct pv_init_ops pv_init_ops  		return ia64_native_ ## name(arg);	\
 	}						\
 
-DEFINE_VOID_FUNC1(fc);
+DEFINE_VOID_FUNC1_VOID(fc);
 DEFINE_VOID_FUNC1(intrin_local_irq_restore);
 
 DEFINE_VOID_FUNC2(ptcga);
@@ -308,6 +315,11 @@ ia64_native_setreg_func(int regnum, unsigned long val)
 	ia64_native_ ## name ## _func(unsigned long arg);	\
 	__DEFINE_FUNC(name, code)
 
+#define DEFINE_VOID_FUNC1_VOID(name, code)			\
+	extern void						\
+	ia64_native_ ## name ## _func(void *arg);		\
+	__DEFINE_FUNC(name, code)
+
 #define DEFINE_VOID_FUNC2(name, code)				\
 	extern void						\
 	ia64_native_ ## name ## _func(unsigned long arg0,	\
@@ -324,8 +336,8 @@ ia64_native_setreg_func(int regnum, unsigned long val)
 	ia64_native_ ## name ## _func(type arg);	\
 	__DEFINE_FUNC(name, code)
 
-DEFINE_VOID_FUNC1(fc,
-		  "fc r8\n");
+DEFINE_VOID_FUNC1_VOID(fc,
+		       "fc r8\n");
 DEFINE_VOID_FUNC1(intrin_local_irq_restore,
 		  ";;\n"
 		  "     cmp.ne p6, p7 = r8, r0\n"
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 64c6f95..68a1311 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -249,7 +249,7 @@ void ia64_patch_phys_stack_reg(unsigned long val)
 	while (offp < end) {
 		ip = (u64) offp + *offp;
 		ia64_patch(ip, mask, imm);
-		ia64_fc(ip);
+		ia64_fc((void *)ip);
 		++offp;
 	}
 	ia64_sync_i();
diff --git a/arch/ia64/kvm/kvm-ia64.c b/arch/ia64/kvm/kvm-ia64.c
index 28f9820..0344c66 100644
--- a/arch/ia64/kvm/kvm-ia64.c
+++ b/arch/ia64/kvm/kvm-ia64.c
@@ -70,7 +70,7 @@ static void kvm_flush_icache(unsigned long start, unsigned long len)
 	int l;
 
 	for (l = 0; l < (len + 32); l += 32)
-		ia64_fc(start + l);
+		ia64_fc((void *)(start + l));
 
 	ia64_sync_i();
 	ia64_srlz_i();
diff --git a/arch/ia64/kvm/vcpu.c b/arch/ia64/kvm/vcpu.c
index ecd526b..6839a52 100644
--- a/arch/ia64/kvm/vcpu.c
+++ b/arch/ia64/kvm/vcpu.c
@@ -390,7 +390,7 @@ void set_rse_reg(struct kvm_pt_regs *regs, unsigned long r1,
 		else
 			*rnat_addr = (*rnat_addr) & (~nat_mask);
 
-		ia64_setreg(_IA64_REG_AR_BSPSTORE, bspstore);
+		ia64_setreg(_IA64_REG_AR_BSPSTORE, (unsigned long)bspstore);
 		ia64_setreg(_IA64_REG_AR_RNAT, rnat);
 	}
 	local_irq_restore(psr);
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index bf3c74c..5e2270a 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -416,6 +416,11 @@ xen_intrin_local_irq_restore(unsigned long mask)
 	xen_ ## name (unsigned long arg);	\
 	__DEFINE_FUNC(name, code)
 
+#define DEFINE_VOID_FUNC1_VOID(name, code)	\
+	extern void				\
+	xen_ ## name (void *arg);		\
+	__DEFINE_FUNC(name, code)
+
 #define DEFINE_VOID_FUNC2(name, code)		\
 	extern void				\
 	xen_ ## name (unsigned long arg0,	\
@@ -530,8 +535,8 @@ DEFINE_FUNC0(get_itc,
 	     "(p6) hint @pause\n"
 	     "(p6) br.cond.spnt 888b\n");
 
-DEFINE_VOID_FUNC1(fc,
-		  "break " __stringify(HYPERPRIVOP_FC) "\n");
+DEFINE_VOID_FUNC1_VOID(fc,
+		       "break " __stringify(HYPERPRIVOP_FC) "\n");
 
 /*
  * psr_i_addr_addr = XEN_PSR_I_ADDR_ADDR
-- 
1.6.0.2



-- 
yamahata
