From: Shaohua Li <shaohua.li@intel.com>
Date: Mon, 25 Feb 2008 08:38:47 +0000
Subject: [patch 3/3] remove duplicate code for register access
Message-Id: <1203928727.3841.21.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have duplicate code to access registers (access_uarea and regset
way). They just have different layout, so remove duplicate code.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/kernel/ptrace.c |  522 +++++++++++++++++-----------------------------
 1 file changed, 200 insertions(+), 322 deletions(-)

Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2008-02-25 15:44:22.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2008-02-25 15:59:31.000000000 +0800
@@ -745,25 +745,6 @@ ia64_sync_fph (struct task_struct *task)
 	psr->dfh = 1;
 }
 
-static int
-access_fr (struct unw_frame_info *info, int regnum, int hi,
-	   unsigned long *data, int write_access)
-{
-	struct ia64_fpreg fpval;
-	int ret;
-
-	ret = unw_get_fr(info, regnum, &fpval);
-	if (ret < 0)
-		return ret;
-
-	if (write_access) {
-		fpval.u.bits[hi] = *data;
-		ret = unw_set_fr(info, regnum, fpval);
-	} else
-		*data = fpval.u.bits[hi];
-	return ret;
-}
-
 /*
  * Change the machine-state of CHILD such that it will return via the normal
  * kernel exit-path, rather than the syscall-exit path.
@@ -865,309 +846,7 @@ access_nat_bits (struct task_struct *chi
 
 static int
 access_uarea (struct task_struct *child, unsigned long addr,
-	      unsigned long *data, int write_access)
-{
-	unsigned long *ptr, regnum, urbs_end, cfm;
-	struct switch_stack *sw;
-	struct pt_regs *pt;
-#	define pt_reg_addr(pt, reg)	((void *)			    \
-					 ((unsigned long) (pt)		    \
-					  + offsetof(struct pt_regs, reg)))
-
-
-	pt = task_pt_regs(child);
-	sw = (struct switch_stack *) (child->thread.ksp + 16);
-
-	if ((addr & 0x7) != 0) {
-		dprintk("ptrace: unaligned register address 0x%lx\n", addr);
-		return -1;
-	}
-
-	if (addr < PT_F127 + 16) {
-		/* accessing fph */
-		if (write_access)
-			ia64_sync_fph(child);
-		else
-			ia64_flush_fph(child);
-		ptr = (unsigned long *)
-			((unsigned long) &child->thread.fph + addr);
-	} else if ((addr >= PT_F10) && (addr < PT_F11 + 16)) {
-		/* scratch registers untouched by kernel (saved in pt_regs) */
-		ptr = pt_reg_addr(pt, f10) + (addr - PT_F10);
-	} else if (addr >= PT_F12 && addr < PT_F15 + 16) {
-		/*
-		 * Scratch registers untouched by kernel (saved in
-		 * switch_stack).
-		 */
-		ptr = (unsigned long *) ((long) sw
-					 + (addr - PT_NAT_BITS - 32));
-	} else if (addr < PT_AR_LC + 8) {
-		/* preserved state: */
-		struct unw_frame_info info;
-		char nat = 0;
-		int ret;
-
-		unw_init_from_blocked_task(&info, child);
-		if (unw_unwind_to_user(&info) < 0)
-			return -1;
-
-		switch (addr) {
-		      case PT_NAT_BITS:
-			return access_nat_bits(child, pt, &info,
-					       data, write_access);
-
-		      case PT_R4: case PT_R5: case PT_R6: case PT_R7:
-			if (write_access) {
-				/* read NaT bit first: */
-				unsigned long dummy;
-
-				ret = unw_get_gr(&info, (addr - PT_R4)/8 + 4,
-						 &dummy, &nat);
-				if (ret < 0)
-					return ret;
-			}
-			return unw_access_gr(&info, (addr - PT_R4)/8 + 4, data,
-					     &nat, write_access);
-
-		      case PT_B1: case PT_B2: case PT_B3:
-		      case PT_B4: case PT_B5:
-			return unw_access_br(&info, (addr - PT_B1)/8 + 1, data,
-					     write_access);
-
-		      case PT_AR_EC:
-			return unw_access_ar(&info, UNW_AR_EC, data,
-					     write_access);
-
-		      case PT_AR_LC:
-			return unw_access_ar(&info, UNW_AR_LC, data,
-					     write_access);
-
-		      default:
-			if (addr >= PT_F2 && addr < PT_F5 + 16)
-				return access_fr(&info, (addr - PT_F2)/16 + 2,
-						 (addr & 8) != 0, data,
-						 write_access);
-			else if (addr >= PT_F16 && addr < PT_F31 + 16)
-				return access_fr(&info,
-						 (addr - PT_F16)/16 + 16,
-						 (addr & 8) != 0,
-						 data, write_access);
-			else {
-				dprintk("ptrace: rejecting access to register "
-					"address 0x%lx\n", addr);
-				return -1;
-			}
-		}
-	} else if (addr < PT_F9+16) {
-		/* scratch state */
-		switch (addr) {
-		      case PT_AR_BSP:
-			/*
-			 * By convention, we use PT_AR_BSP to refer to
-			 * the end of the user-level backing store.
-			 * Use ia64_rse_skip_regs(PT_AR_BSP, -CFM.sof)
-			 * to get the real value of ar.bsp at the time
-			 * the kernel was entered.
-			 *
-			 * Furthermore, when changing the contents of
-			 * PT_AR_BSP (or PT_CFM) while the task is
-			 * blocked in a system call, convert the state
-			 * so that the non-system-call exit
-			 * path is used.  This ensures that the proper
-			 * state will be picked up when resuming
-			 * execution.  However, it *also* means that
-			 * once we write PT_AR_BSP/PT_CFM, it won't be
-			 * possible to modify the syscall arguments of
-			 * the pending system call any longer.  This
-			 * shouldn't be an issue because modifying
-			 * PT_AR_BSP/PT_CFM generally implies that
-			 * we're either abandoning the pending system
-			 * call or that we defer it's re-execution
-			 * (e.g., due to GDB doing an inferior
-			 * function call).
-			 */
-			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
-			if (write_access) {
-				if (*data != urbs_end) {
-					if (in_syscall(pt))
-						convert_to_non_syscall(child,
-								       pt,
-								       cfm);
-					/*
-					 * Simulate user-level write
-					 * of ar.bsp:
-					 */
-					pt->loadrs = 0;
-					pt->ar_bspstore = *data;
-				}
-			} else
-				*data = urbs_end;
-			return 0;
-
-		      case PT_CFM:
-			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
-			if (write_access) {
-				if (((cfm ^ *data) & PFM_MASK) != 0) {
-					if (in_syscall(pt))
-						convert_to_non_syscall(child,
-								       pt,
-								       cfm);
-					pt->cr_ifs = ((pt->cr_ifs & ~PFM_MASK)
-						      | (*data & PFM_MASK));
-				}
-			} else
-				*data = cfm;
-			return 0;
-
-		      case PT_CR_IPSR:
-			if (write_access) {
-				unsigned long tmp = *data;
-				/* psr.ri=3 is a reserved value: SDM 2:25 */
-				if ((tmp & IA64_PSR_RI) = IA64_PSR_RI)
-					tmp &= ~IA64_PSR_RI;
-				pt->cr_ipsr = ((tmp & IPSR_MASK)
-					       | (pt->cr_ipsr & ~IPSR_MASK));
-			} else
-				*data = (pt->cr_ipsr & IPSR_MASK);
-			return 0;
-
-		      case PT_AR_RSC:
-			if (write_access)
-				pt->ar_rsc = *data | (3 << 2); /* force PL3 */
-			else
-				*data = pt->ar_rsc;
-			return 0;
-
-		      case PT_AR_RNAT:
-			ptr = pt_reg_addr(pt, ar_rnat);
-			break;
-		      case PT_R1:
-			ptr = pt_reg_addr(pt, r1);
-			break;
-		      case PT_R2:  case PT_R3:
-			ptr = pt_reg_addr(pt, r2) + (addr - PT_R2);
-			break;
-		      case PT_R8:  case PT_R9:  case PT_R10: case PT_R11:
-			ptr = pt_reg_addr(pt, r8) + (addr - PT_R8);
-			break;
-		      case PT_R12: case PT_R13:
-			ptr = pt_reg_addr(pt, r12) + (addr - PT_R12);
-			break;
-		      case PT_R14:
-			ptr = pt_reg_addr(pt, r14);
-			break;
-		      case PT_R15:
-			ptr = pt_reg_addr(pt, r15);
-			break;
-		      case PT_R16: case PT_R17: case PT_R18: case PT_R19:
-		      case PT_R20: case PT_R21: case PT_R22: case PT_R23:
-		      case PT_R24: case PT_R25: case PT_R26: case PT_R27:
-		      case PT_R28: case PT_R29: case PT_R30: case PT_R31:
-			ptr = pt_reg_addr(pt, r16) + (addr - PT_R16);
-			break;
-		      case PT_B0:
-			ptr = pt_reg_addr(pt, b0);
-			break;
-		      case PT_B6:
-			ptr = pt_reg_addr(pt, b6);
-			break;
-		      case PT_B7:
-			ptr = pt_reg_addr(pt, b7);
-			break;
-		      case PT_F6:  case PT_F6+8: case PT_F7: case PT_F7+8:
-		      case PT_F8:  case PT_F8+8: case PT_F9: case PT_F9+8:
-			ptr = pt_reg_addr(pt, f6) + (addr - PT_F6);
-			break;
-		      case PT_AR_BSPSTORE:
-			ptr = pt_reg_addr(pt, ar_bspstore);
-			break;
-		      case PT_AR_UNAT:
-			ptr = pt_reg_addr(pt, ar_unat);
-			break;
-		      case PT_AR_PFS:
-			ptr = pt_reg_addr(pt, ar_pfs);
-			break;
-		      case PT_AR_CCV:
-			ptr = pt_reg_addr(pt, ar_ccv);
-			break;
-		      case PT_AR_FPSR:
-			ptr = pt_reg_addr(pt, ar_fpsr);
-			break;
-		      case PT_CR_IIP:
-			ptr = pt_reg_addr(pt, cr_iip);
-			break;
-		      case PT_PR:
-			ptr = pt_reg_addr(pt, pr);
-			break;
-			/* scratch register */
-
-		      default:
-			/* disallow accessing anything else... */
-			dprintk("ptrace: rejecting access to register "
-				"address 0x%lx\n", addr);
-			return -1;
-		}
-	} else if (addr <= PT_AR_SSD) {
-		ptr = pt_reg_addr(pt, ar_csd) + (addr - PT_AR_CSD);
-	} else {
-		/* access debug registers */
-
-		if (addr >= PT_IBR) {
-			regnum = (addr - PT_IBR) >> 3;
-			ptr = &child->thread.ibr[0];
-		} else {
-			regnum = (addr - PT_DBR) >> 3;
-			ptr = &child->thread.dbr[0];
-		}
-
-		if (regnum >= 8) {
-			dprintk("ptrace: rejecting access to register "
-				"address 0x%lx\n", addr);
-			return -1;
-		}
-#ifdef CONFIG_PERFMON
-		/*
-		 * Check if debug registers are used by perfmon. This
-		 * test must be done once we know that we can do the
-		 * operation, i.e. the arguments are all valid, but
-		 * before we start modifying the state.
-		 *
-		 * Perfmon needs to keep a count of how many processes
-		 * are trying to modify the debug registers for system
-		 * wide monitoring sessions.
-		 *
-		 * We also include read access here, because they may
-		 * cause the PMU-installed debug register state
-		 * (dbr[], ibr[]) to be reset. The two arrays are also
-		 * used by perfmon, but we do not use
-		 * IA64_THREAD_DBG_VALID. The registers are restored
-		 * by the PMU context switch code.
-		 */
-		if (pfm_use_debug_registers(child)) return -1;
-#endif
-
-		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
-			child->thread.flags |= IA64_THREAD_DBG_VALID;
-			memset(child->thread.dbr, 0,
-			       sizeof(child->thread.dbr));
-			memset(child->thread.ibr, 0,
-			       sizeof(child->thread.ibr));
-		}
-
-		ptr += regnum;
-
-		if ((regnum & 1) && write_access) {
-			/* don't let the user set kernel-level breakpoints: */
-			*ptr = *data & ~(7UL << 56);
-			return 0;
-		}
-	}
-	if (write_access)
-		*ptr = *data;
-	else
-		*data = *ptr;
-	return 0;
-}
+	      unsigned long *data, int write_access);
 
 static long
 ptrace_getregs (struct task_struct *child, struct pt_all_user_regs __user *ppr)
@@ -2296,6 +1975,205 @@ static int fpregs_set(struct task_struct
 		kbuf, ubuf);
 }
 
+static int
+access_uarea(struct task_struct *child, unsigned long addr,
+	      unsigned long *data, int write_access)
+{
+	unsigned int pos = -1; /* an invalid value */
+	int ret;
+	unsigned long *ptr, regnum;
+
+	if ((addr & 0x7) != 0) {
+		dprintk("ptrace: unaligned register address 0x%lx\n", addr);
+		return -1;
+	}
+	if ((addr >= PT_NAT_BITS + 8 && addr < PT_F2) ||
+		(addr >= PT_R7 + 8 && addr < PT_B1) ||
+		(addr >= PT_AR_LC + 8 && addr < PT_CR_IPSR) ||
+		(addr >= PT_AR_SSD + 8 && addr < PT_DBR)) {
+		dprintk("ptrace: rejecting access to register "
+					"address 0x%lx\n", addr);
+		return -1;
+	}
+
+	switch (addr) {
+	case PT_F32 ... (PT_F127 + 15):
+		pos = addr - PT_F32 + ELF_FP_OFFSET(32);
+		break;
+	case PT_F2 ... (PT_F5 + 15):
+		pos = addr - PT_F2 + ELF_FP_OFFSET(2);
+		break;
+	case PT_F10 ... (PT_F31 + 15):
+		pos = addr - PT_F10 + ELF_FP_OFFSET(10);
+		break;
+	case PT_F6 ... (PT_F9 + 15):
+		pos = addr - PT_F6 + ELF_FP_OFFSET(6);
+		break;
+	}
+
+	if (pos != -1) {
+		if (write_access)
+			ret = fpregs_set(child, NULL, pos,
+				sizeof(unsigned long), data, NULL);
+		else
+			ret = fpregs_get(child, NULL, pos,
+				sizeof(unsigned long), data, NULL);
+		if (ret != 0)
+			return -1;
+		return 0;
+	}
+
+	switch (addr) {
+	case PT_NAT_BITS:
+		pos = ELF_NAT_OFFSET;
+		break;
+	case PT_R4 ... PT_R7:
+		pos = addr - PT_R4 + ELF_GR_OFFSET(4);
+		break;
+	case PT_B1 ... PT_B5:
+		pos = addr - PT_B1 + ELF_BR_OFFSET(1);
+		break;
+	case PT_AR_EC:
+		pos = ELF_AR_EC_OFFSET;
+		break;
+	case PT_AR_LC:
+		pos = ELF_AR_LC_OFFSET;
+		break;
+	case PT_CR_IPSR:
+		pos = ELF_CR_IPSR_OFFSET;
+		break;
+	case PT_CR_IIP:
+		pos = ELF_CR_IIP_OFFSET;
+		break;
+	case PT_CFM:
+		pos = ELF_CFM_OFFSET;
+		break;
+	case PT_AR_UNAT:
+		pos = ELF_AR_UNAT_OFFSET;
+		break;
+	case PT_AR_PFS:
+		pos = ELF_AR_PFS_OFFSET;
+		break;
+	case PT_AR_RSC:
+		pos = ELF_AR_RSC_OFFSET;
+		break;
+	case PT_AR_RNAT:
+		pos = ELF_AR_RNAT_OFFSET;
+		break;
+	case PT_AR_BSPSTORE:
+		pos = ELF_AR_BSPSTORE_OFFSET;
+		break;
+	case PT_PR:
+		pos = ELF_PR_OFFSET;
+		break;
+	case PT_B6:
+		pos = ELF_BR_OFFSET(6);
+		break;
+	case PT_AR_BSP:
+		pos = ELF_AR_BSP_OFFSET;
+		break;
+	case PT_R1 ... PT_R3:
+		pos = addr - PT_R1 + ELF_GR_OFFSET(1);
+		break;
+	case PT_R12 ... PT_R15:
+		pos = addr - PT_R12 + ELF_GR_OFFSET(12);
+		break;
+	case PT_R8 ... PT_R11:
+		pos = addr - PT_R8 + ELF_GR_OFFSET(8);
+		break;
+	case PT_R16 ... PT_R31:
+		pos = addr - PT_R16 + ELF_GR_OFFSET(16);
+		break;
+	case PT_AR_CCV:
+		pos = ELF_AR_CCV_OFFSET;
+		break;
+	case PT_AR_FPSR:
+		pos = ELF_AR_FPSR_OFFSET;
+		break;
+	case PT_B0:
+		pos = ELF_BR_OFFSET(0);
+		break;
+	case PT_B7:
+		pos = ELF_BR_OFFSET(7);
+		break;
+	case PT_AR_CSD:
+		pos = ELF_AR_CSD_OFFSET;
+		break;
+	case PT_AR_SSD:
+		pos = ELF_AR_SSD_OFFSET;
+		break;
+	}
+
+	if (pos != -1) {
+		if (write_access)
+			ret = gpregs_set(child, NULL, pos,
+				sizeof(unsigned long), data, NULL);
+		else
+			ret = gpregs_get(child, NULL, pos,
+				sizeof(unsigned long), data, NULL);
+		if (ret != 0)
+			return -1;
+		return 0;
+	}
+
+	/* access debug registers */
+	if (addr >= PT_IBR) {
+		regnum = (addr - PT_IBR) >> 3;
+		ptr = &child->thread.ibr[0];
+	} else {
+		regnum = (addr - PT_DBR) >> 3;
+		ptr = &child->thread.dbr[0];
+	}
+
+	if (regnum >= 8) {
+		dprintk("ptrace: rejecting access to register "
+				"address 0x%lx\n", addr);
+		return -1;
+	}
+#ifdef CONFIG_PERFMON
+	/*
+	 * Check if debug registers are used by perfmon. This
+	 * test must be done once we know that we can do the
+	 * operation, i.e. the arguments are all valid, but
+	 * before we start modifying the state.
+	 *
+	 * Perfmon needs to keep a count of how many processes
+	 * are trying to modify the debug registers for system
+	 * wide monitoring sessions.
+	 *
+	 * We also include read access here, because they may
+	 * cause the PMU-installed debug register state
+	 * (dbr[], ibr[]) to be reset. The two arrays are also
+	 * used by perfmon, but we do not use
+	 * IA64_THREAD_DBG_VALID. The registers are restored
+	 * by the PMU context switch code.
+	 */
+	if (pfm_use_debug_registers(child))
+		return -1;
+#endif
+
+	if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
+		child->thread.flags |= IA64_THREAD_DBG_VALID;
+		memset(child->thread.dbr, 0,
+				sizeof(child->thread.dbr));
+		memset(child->thread.ibr, 0,
+				sizeof(child->thread.ibr));
+	}
+
+	ptr += regnum;
+
+	if ((regnum & 1) && write_access) {
+		/* don't let the user set kernel-level breakpoints: */
+		*ptr = *data & ~(7UL << 56);
+		return 0;
+	}
+	if (write_access)
+		*ptr = *data;
+	else
+		*data = *ptr;
+	return 0;
+}
+
 static const struct user_regset native_regsets[] = {
 	{
 		.core_note_type = NT_PRSTATUS,


