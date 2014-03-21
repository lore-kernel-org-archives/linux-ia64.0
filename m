From: Richard Guy Briggs <rgb@redhat.com>
Date: Fri, 21 Mar 2014 19:18:08 +0000
Subject: Re: [PATCH 4/4] ARCH: AUDIT: audit_syscall_entry() should not require the arch
Message-Id: <20140321191808.GF16467@madcap2.tricolour.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1395266643-3139-1-git-send-email-eparis@redhat.com>
 <1395266643-3139-4-git-send-email-eparis@redhat.com>
In-Reply-To: <1395266643-3139-4-git-send-email-eparis@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 14/03/19, Eric Paris wrote:
> We have a function where the arch can be queried, syscall_get_arch().
> So rather than have every single piece of arch specific code use and/or
> duplicate syscall_get_arch(), just have the audit code use the
> syscall_get_arch() code.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: microblaze-uclinux@itee.uq.edu.au
> Cc: linux-mips@linux-mips.org
> Cc: linux@lists.openrisc.net
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: user-mode-linux-devel@lists.sourceforge.net
> Cc: linux-xtensa@linux-xtensa.org
> Cc: x86@kernel.org

Acked-by: Richard Guy Briggs <rgb@redhat.com>

> ---
>  arch/alpha/kernel/ptrace.c      |  2 +-
>  arch/arm/kernel/ptrace.c        |  4 ++--
>  arch/ia64/kernel/ptrace.c       |  2 +-
>  arch/microblaze/kernel/ptrace.c |  3 +--
>  arch/mips/kernel/ptrace.c       |  4 +---
>  arch/openrisc/kernel/ptrace.c   |  3 +--
>  arch/parisc/kernel/ptrace.c     |  9 +++------
>  arch/powerpc/kernel/ptrace.c    |  7 ++-----
>  arch/s390/kernel/ptrace.c       |  4 +---
>  arch/sh/kernel/ptrace_32.c      | 14 +-------------
>  arch/sh/kernel/ptrace_64.c      | 17 +----------------
>  arch/sparc/kernel/ptrace_64.c   |  9 ++-------
>  arch/um/kernel/ptrace.c         |  3 +--
>  arch/x86/kernel/ptrace.c        |  8 ++------
>  arch/x86/um/asm/ptrace.h        |  4 ----
>  arch/xtensa/kernel/ptrace.c     |  2 +-
>  include/linux/audit.h           |  7 ++++---
>  17 files changed, 25 insertions(+), 77 deletions(-)
> 
> diff --git a/arch/alpha/kernel/ptrace.c b/arch/alpha/kernel/ptrace.c
> index 86d8351..d9ee817 100644
> --- a/arch/alpha/kernel/ptrace.c
> +++ b/arch/alpha/kernel/ptrace.c
> @@ -321,7 +321,7 @@ asmlinkage unsigned long syscall_trace_enter(void)
>  	if (test_thread_flag(TIF_SYSCALL_TRACE) &&
>  	    tracehook_report_syscall_entry(current_pt_regs()))
>  		ret = -1UL;
> -	audit_syscall_entry(AUDIT_ARCH_ALPHA, regs->r0, regs->r16, regs->r17, regs->r18, regs->r19);
> +	audit_syscall_entry(regs->r0, regs->r16, regs->r17, regs->r18, regs->r19);
>  	return ret ?: current_pt_regs()->r0;
>  }
>  
> diff --git a/arch/arm/kernel/ptrace.c b/arch/arm/kernel/ptrace.c
> index 0dd3b79..c9d2b34 100644
> --- a/arch/arm/kernel/ptrace.c
> +++ b/arch/arm/kernel/ptrace.c
> @@ -943,8 +943,8 @@ asmlinkage int syscall_trace_enter(struct pt_regs *regs, int scno)
>  	if (test_thread_flag(TIF_SYSCALL_TRACEPOINT))
>  		trace_sys_enter(regs, scno);
>  
> -	audit_syscall_entry(AUDIT_ARCH_ARM, scno, regs->ARM_r0, regs->ARM_r1,
> -			    regs->ARM_r2, regs->ARM_r3);
> +	audit_syscall_entry(scno, regs->ARM_r0, regs->ARM_r1, regs->ARM_r2,
> +			    regs->ARM_r3);
>  
>  	return scno;
>  }
> diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
> index b7a5fff..6f54d51 100644
> --- a/arch/ia64/kernel/ptrace.c
> +++ b/arch/ia64/kernel/ptrace.c
> @@ -1219,7 +1219,7 @@ syscall_trace_enter (long arg0, long arg1, long arg2, long arg3,
>  		ia64_sync_krbs();
>  
>  
> -	audit_syscall_entry(AUDIT_ARCH_IA64, regs.r15, arg0, arg1, arg2, arg3);
> +	audit_syscall_entry(regs.r15, arg0, arg1, arg2, arg3);
>  
>  	return 0;
>  }
> diff --git a/arch/microblaze/kernel/ptrace.c b/arch/microblaze/kernel/ptrace.c
> index 39cf508..bb10637 100644
> --- a/arch/microblaze/kernel/ptrace.c
> +++ b/arch/microblaze/kernel/ptrace.c
> @@ -147,8 +147,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
>  		 */
>  		ret = -1L;
>  
> -	audit_syscall_entry(EM_MICROBLAZE, regs->r12, regs->r5, regs->r6,
> -			    regs->r7, regs->r8);
> +	audit_syscall_entry(regs->r12, regs->r5, regs->r6, regs->r7, regs->r8);
>  
>  	return ret ?: regs->r12;
>  }
> diff --git a/arch/mips/kernel/ptrace.c b/arch/mips/kernel/ptrace.c
> index 65ba622..c06bb82 100644
> --- a/arch/mips/kernel/ptrace.c
> +++ b/arch/mips/kernel/ptrace.c
> @@ -671,9 +671,7 @@ asmlinkage void syscall_trace_enter(struct pt_regs *regs)
>  	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
>  		trace_sys_enter(regs, regs->regs[2]);
>  
> -	audit_syscall_entry(syscall_get_arch(),
> -			    regs->regs[2],
> -			    regs->regs[4], regs->regs[5],
> +	audit_syscall_entry(regs->regs[2], regs->regs[4], regs->regs[5],
>  			    regs->regs[6], regs->regs[7]);
>  }
>  
> diff --git a/arch/openrisc/kernel/ptrace.c b/arch/openrisc/kernel/ptrace.c
> index 71a2a0c..4f59fa4 100644
> --- a/arch/openrisc/kernel/ptrace.c
> +++ b/arch/openrisc/kernel/ptrace.c
> @@ -187,8 +187,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
>  		 */
>  		ret = -1L;
>  
> -	audit_syscall_entry(AUDIT_ARCH_OPENRISC, regs->gpr[11],
> -			    regs->gpr[3], regs->gpr[4],
> +	audit_syscall_entry(regs->gpr[11], regs->gpr[3], regs->gpr[4],
>  			    regs->gpr[5], regs->gpr[6]);
>  
>  	return ret ? : regs->gpr[11];
> diff --git a/arch/parisc/kernel/ptrace.c b/arch/parisc/kernel/ptrace.c
> index e842ee2..7481457 100644
> --- a/arch/parisc/kernel/ptrace.c
> +++ b/arch/parisc/kernel/ptrace.c
> @@ -276,14 +276,11 @@ long do_syscall_trace_enter(struct pt_regs *regs)
>  
>  #ifdef CONFIG_64BIT
>  	if (!is_compat_task())
> -		audit_syscall_entry(AUDIT_ARCH_PARISC64,
> -			regs->gr[20],
> -			regs->gr[26], regs->gr[25],
> -			regs->gr[24], regs->gr[23]);
> +		audit_syscall_entry(regs->gr[20], regs->gr[26], regs->gr[25],
> +				    regs->gr[24], regs->gr[23]);
>  	else
>  #endif
> -		audit_syscall_entry(AUDIT_ARCH_PARISC,
> -			regs->gr[20] & 0xffffffff,
> +		audit_syscall_entry(regs->gr[20] & 0xffffffff,
>  			regs->gr[26] & 0xffffffff,
>  			regs->gr[25] & 0xffffffff,
>  			regs->gr[24] & 0xffffffff,
> diff --git a/arch/powerpc/kernel/ptrace.c b/arch/powerpc/kernel/ptrace.c
> index 2e3d2bf..524a943 100644
> --- a/arch/powerpc/kernel/ptrace.c
> +++ b/arch/powerpc/kernel/ptrace.c
> @@ -1788,14 +1788,11 @@ long do_syscall_trace_enter(struct pt_regs *regs)
>  
>  #ifdef CONFIG_PPC64
>  	if (!is_32bit_task())
> -		audit_syscall_entry(AUDIT_ARCH_PPC64,
> -				    regs->gpr[0],
> -				    regs->gpr[3], regs->gpr[4],
> +		audit_syscall_entry(regs->gpr[0], regs->gpr[3], regs->gpr[4],
>  				    regs->gpr[5], regs->gpr[6]);
>  	else
>  #endif
> -		audit_syscall_entry(AUDIT_ARCH_PPC,
> -				    regs->gpr[0],
> +		audit_syscall_entry(regs->gpr[0],
>  				    regs->gpr[3] & 0xffffffff,
>  				    regs->gpr[4] & 0xffffffff,
>  				    regs->gpr[5] & 0xffffffff,
> diff --git a/arch/s390/kernel/ptrace.c b/arch/s390/kernel/ptrace.c
> index e65c91c..2e2e7bb5 100644
> --- a/arch/s390/kernel/ptrace.c
> +++ b/arch/s390/kernel/ptrace.c
> @@ -812,9 +812,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
>  	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
>  		trace_sys_enter(regs, regs->gprs[2]);
>  
> -	audit_syscall_entry(is_compat_task() ?
> -				AUDIT_ARCH_S390 : AUDIT_ARCH_S390X,
> -			    regs->gprs[2], regs->orig_gpr2,
> +	audit_syscall_entry(regs->gprs[2], regs->orig_gpr2,
>  			    regs->gprs[3], regs->gprs[4],
>  			    regs->gprs[5]);
>  out:
> diff --git a/arch/sh/kernel/ptrace_32.c b/arch/sh/kernel/ptrace_32.c
> index 668c816..c1a6b89 100644
> --- a/arch/sh/kernel/ptrace_32.c
> +++ b/arch/sh/kernel/ptrace_32.c
> @@ -484,17 +484,6 @@ long arch_ptrace(struct task_struct *child, long request,
>  	return ret;
>  }
>  
> -static inline int audit_arch(void)
> -{
> -	int arch = EM_SH;
> -
> -#ifdef CONFIG_CPU_LITTLE_ENDIAN
> -	arch |= __AUDIT_ARCH_LE;
> -#endif
> -
> -	return arch;
> -}
> -
>  asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
>  {
>  	long ret = 0;
> @@ -513,8 +502,7 @@ asmlinkage long do_syscall_trace_enter(struct pt_regs *regs)
>  	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
>  		trace_sys_enter(regs, regs->regs[0]);
>  
> -	audit_syscall_entry(audit_arch(), regs->regs[3],
> -			    regs->regs[4], regs->regs[5],
> +	audit_syscall_entry(regs->regs[3], regs->regs[4], regs->regs[5],
>  			    regs->regs[6], regs->regs[7]);
>  
>  	return ret ?: regs->regs[0];
> diff --git a/arch/sh/kernel/ptrace_64.c b/arch/sh/kernel/ptrace_64.c
> index af90339..5cea973 100644
> --- a/arch/sh/kernel/ptrace_64.c
> +++ b/arch/sh/kernel/ptrace_64.c
> @@ -504,20 +504,6 @@ asmlinkage int sh64_ptrace(long request, long pid,
>  	return sys_ptrace(request, pid, addr, data);
>  }
>  
> -static inline int audit_arch(void)
> -{
> -	int arch = EM_SH;
> -
> -#ifdef CONFIG_64BIT
> -	arch |= __AUDIT_ARCH_64BIT;
> -#endif
> -#ifdef CONFIG_CPU_LITTLE_ENDIAN
> -	arch |= __AUDIT_ARCH_LE;
> -#endif
> -
> -	return arch;
> -}
> -
>  asmlinkage long long do_syscall_trace_enter(struct pt_regs *regs)
>  {
>  	long long ret = 0;
> @@ -536,8 +522,7 @@ asmlinkage long long do_syscall_trace_enter(struct pt_regs *regs)
>  	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
>  		trace_sys_enter(regs, regs->regs[9]);
>  
> -	audit_syscall_entry(audit_arch(), regs->regs[1],
> -			    regs->regs[2], regs->regs[3],
> +	audit_syscall_entry(regs->regs[1], regs->regs[2], regs->regs[3],
>  			    regs->regs[4], regs->regs[5]);
>  
>  	return ret ?: regs->regs[9];
> diff --git a/arch/sparc/kernel/ptrace_64.c b/arch/sparc/kernel/ptrace_64.c
> index c13c9f2..9ddc492 100644
> --- a/arch/sparc/kernel/ptrace_64.c
> +++ b/arch/sparc/kernel/ptrace_64.c
> @@ -1076,13 +1076,8 @@ asmlinkage int syscall_trace_enter(struct pt_regs *regs)
>  	if (unlikely(test_thread_flag(TIF_SYSCALL_TRACEPOINT)))
>  		trace_sys_enter(regs, regs->u_regs[UREG_G1]);
>  
> -	audit_syscall_entry((test_thread_flag(TIF_32BIT) ?
> -			     AUDIT_ARCH_SPARC :
> -			     AUDIT_ARCH_SPARC64),
> -			    regs->u_regs[UREG_G1],
> -			    regs->u_regs[UREG_I0],
> -			    regs->u_regs[UREG_I1],
> -			    regs->u_regs[UREG_I2],
> +	audit_syscall_entry(regs->u_regs[UREG_G1], regs->u_regs[UREG_I0],
> +			    regs->u_regs[UREG_I1], regs->u_regs[UREG_I2],
>  			    regs->u_regs[UREG_I3]);
>  
>  	return ret;
> diff --git a/arch/um/kernel/ptrace.c b/arch/um/kernel/ptrace.c
> index 694d551..62435ef 100644
> --- a/arch/um/kernel/ptrace.c
> +++ b/arch/um/kernel/ptrace.c
> @@ -165,8 +165,7 @@ static void send_sigtrap(struct task_struct *tsk, struct uml_pt_regs *regs,
>   */
>  void syscall_trace_enter(struct pt_regs *regs)
>  {
> -	audit_syscall_entry(HOST_AUDIT_ARCH,
> -			    UPT_SYSCALL_NR(&regs->regs),
> +	audit_syscall_entry(UPT_SYSCALL_NR(&regs->regs),
>  			    UPT_SYSCALL_ARG1(&regs->regs),
>  			    UPT_SYSCALL_ARG2(&regs->regs),
>  			    UPT_SYSCALL_ARG3(&regs->regs),
> diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
> index 7461f50..46dfba6 100644
> --- a/arch/x86/kernel/ptrace.c
> +++ b/arch/x86/kernel/ptrace.c
> @@ -1488,15 +1488,11 @@ long syscall_trace_enter(struct pt_regs *regs)
>  		trace_sys_enter(regs, regs->orig_ax);
>  
>  	if (IS_IA32)
> -		audit_syscall_entry(AUDIT_ARCH_I386,
> -				    regs->orig_ax,
> -				    regs->bx, regs->cx,
> +		audit_syscall_entry(regs->orig_ax, regs->bx, regs->cx,
>  				    regs->dx, regs->si);
>  #ifdef CONFIG_X86_64
>  	else
> -		audit_syscall_entry(AUDIT_ARCH_X86_64,
> -				    regs->orig_ax,
> -				    regs->di, regs->si,
> +		audit_syscall_entry(regs->orig_ax, regs->di, regs->si,
>  				    regs->dx, regs->r10);
>  #endif
>  
> diff --git a/arch/x86/um/asm/ptrace.h b/arch/x86/um/asm/ptrace.h
> index 54f8102..e59eef2 100644
> --- a/arch/x86/um/asm/ptrace.h
> +++ b/arch/x86/um/asm/ptrace.h
> @@ -47,8 +47,6 @@ struct user_desc;
>  
>  #ifdef CONFIG_X86_32
>  
> -#define HOST_AUDIT_ARCH AUDIT_ARCH_I386
> -
>  extern int ptrace_get_thread_area(struct task_struct *child, int idx,
>                                    struct user_desc __user *user_desc);
>  
> @@ -57,8 +55,6 @@ extern int ptrace_set_thread_area(struct task_struct *child, int idx,
>  
>  #else
>  
> -#define HOST_AUDIT_ARCH AUDIT_ARCH_X86_64
> -
>  #define PT_REGS_R8(r) UPT_R8(&(r)->regs)
>  #define PT_REGS_R9(r) UPT_R9(&(r)->regs)
>  #define PT_REGS_R10(r) UPT_R10(&(r)->regs)
> diff --git a/arch/xtensa/kernel/ptrace.c b/arch/xtensa/kernel/ptrace.c
> index 562fac6..4d54b48 100644
> --- a/arch/xtensa/kernel/ptrace.c
> +++ b/arch/xtensa/kernel/ptrace.c
> @@ -342,7 +342,7 @@ void do_syscall_trace_enter(struct pt_regs *regs)
>  		do_syscall_trace();
>  
>  #if 0
> -	audit_syscall_entry(current, AUDIT_ARCH_XTENSA..);
> +	audit_syscall_entry(...);
>  #endif
>  }
>  
> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 4b2983e..62c9d98 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -26,6 +26,7 @@
>  #include <linux/sched.h>
>  #include <linux/ptrace.h>
>  #include <uapi/linux/audit.h>
> +#include <asm/syscall.h>
>  
>  struct audit_sig_info {
>  	uid_t		uid;
> @@ -135,12 +136,12 @@ static inline void audit_free(struct task_struct *task)
>  	if (unlikely(task->audit_context))
>  		__audit_free(task);
>  }
> -static inline void audit_syscall_entry(int arch, int major, unsigned long a0,
> +static inline void audit_syscall_entry(int major, unsigned long a0,
>  				       unsigned long a1, unsigned long a2,
>  				       unsigned long a3)
>  {
>  	if (unlikely(current->audit_context))
> -		__audit_syscall_entry(arch, major, a0, a1, a2, a3);
> +		__audit_syscall_entry(syscall_get_arch(), major, a0, a1, a2, a3);
>  }
>  static inline void audit_syscall_exit(void *pt_regs)
>  {
> @@ -316,7 +317,7 @@ static inline int audit_alloc(struct task_struct *task)
>  }
>  static inline void audit_free(struct task_struct *task)
>  { }
> -static inline void audit_syscall_entry(int arch, int major, unsigned long a0,
> +static inline void audit_syscall_entry(int major, unsigned long a0,
>  				       unsigned long a1, unsigned long a2,
>  				       unsigned long a3)
>  { }
> -- 
> 1.8.5.3
> 
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
