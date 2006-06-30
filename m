From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Fri, 30 Jun 2006 18:54:44 +0000
Subject: Re: [PATCH] IA64 kprobe invalidate icache of jump buffer
Message-Id: <20060630115443.A27034@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44A482C9.3090607@intel.com>
In-Reply-To: <44A482C9.3090607@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 30, 2006 at 01:47:53AM +0000, bibo, mao wrote:
> Hi, 
>   Kprobe inserts breakpoint instruction in probepoint and then jumps
> to instruction slot when breakpoint is hit, the instruction slot icache
> must be consistent with dcache. Here is the patch which invalidates
> instruction slot icache area in IA64 platform.
>   Without this patch, in some machines there will be fault when executing
> instruction slot where icache content is inconsistent with dcache.
> 
>  Signed-off-by: bibo,mao <bibo.mao@intel.com> 
Bibo,
	This patch looks lot better than your earlier one.
Please see minor comments below and once you fix them please
post the same onto lkml for inclusion.

> 
> -------------------------------------------------------------------------------
> 
> diff -Nruap 2.6.17.org/arch/ia64/kernel/kprobes.c 2.6.17/arch/ia64/kernel/kprobes.c
> --- 2.6.17.org/arch/ia64/kernel/kprobes.c	2006-06-29 03:50:15.000000000 +0800
> +++ 2.6.17/arch/ia64/kernel/kprobes.c	2006-06-30 02:24:42.000000000 +0800
> @@ -456,6 +456,8 @@ void __kprobes arch_arm_kprobe(struct kp
>  
>  	memcpy((char *)arm_addr, &p->ainsn.insn.bundle, sizeof(bundle_t));
>  	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
> +	arm_addr = (unsigned long)&p->opcode.bundle & ~0xFULL;
> +	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
Please use flush_insn_slot() instead of the above two line change
and should move above memcpy() as you need to flush the jump buffer before
arming the probe.
>  }
>  
>  void __kprobes arch_disarm_kprobe(struct kprobe *p)
> @@ -468,6 +470,14 @@ void __kprobes arch_disarm_kprobe(struct
>  	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
>  }
>  
> +void __kprobes flush_insn_slot(struct kprobe *p)
> +{
> +	unsigned long arm_addr;
> +
> +	arm_addr = ((unsigned long)&p->opcode.bundle) & ~0xFULL;
> +	flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
> +}
> +
>  /*
>   * We are resuming execution after a single step fault, so the pt_regs
>   * structure reflects the register state after we executed the instruction
> diff -Nruap 2.6.17.org/include/asm-i386/kprobes.h 2.6.17/include/asm-i386/kprobes.h
> --- 2.6.17.org/include/asm-i386/kprobes.h	2006-06-29 03:50:18.000000000 +0800
> +++ 2.6.17/include/asm-i386/kprobes.h	2006-06-30 02:32:17.000000000 +0800
> @@ -44,6 +44,7 @@ typedef u8 kprobe_opcode_t;
>  
>  #define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
>  #define ARCH_SUPPORTS_KRETPROBES
> +#define flush_insn_slot(p)	do { } while (0)
>  
>  void arch_remove_kprobe(struct kprobe *p);
>  void kretprobe_trampoline(void);
> diff -Nruap 2.6.17.org/include/asm-ia64/kprobes.h 2.6.17/include/asm-ia64/kprobes.h
> --- 2.6.17.org/include/asm-ia64/kprobes.h	2006-03-27 14:41:22.000000000 +0800
> +++ 2.6.17/include/asm-ia64/kprobes.h	2006-06-30 02:33:04.000000000 +0800
> @@ -124,5 +124,6 @@ static inline void jprobe_return(void)
>  }
>  extern void invalidate_stacked_regs(void);
>  extern void flush_register_stack(void);
> +extern void flush_insn_slot(struct kprobe *p);
>  
>  #endif				/* _ASM_KPROBES_H */
> diff -Nruap 2.6.17.org/include/asm-powerpc/kprobes.h 2.6.17/include/asm-powerpc/kprobes.h
> --- 2.6.17.org/include/asm-powerpc/kprobes.h	2006-03-27 14:41:22.000000000 +0800
> +++ 2.6.17/include/asm-powerpc/kprobes.h	2006-06-30 02:32:34.000000000 +0800
> @@ -50,6 +50,7 @@ typedef unsigned int kprobe_opcode_t;
>  			IS_TWI(instr) || IS_TDI(instr))
>  
>  #define ARCH_SUPPORTS_KRETPROBES
> +#define flush_insn_slot(p)	do { } while (0)
>  void kretprobe_trampoline(void);
>  extern void arch_remove_kprobe(struct kprobe *p);
>  
> diff -Nruap 2.6.17.org/include/asm-sparc64/kprobes.h 2.6.17/include/asm-sparc64/kprobes.h
> --- 2.6.17.org/include/asm-sparc64/kprobes.h	2006-03-27 14:41:23.000000000 +0800
> +++ 2.6.17/include/asm-sparc64/kprobes.h	2006-06-30 02:32:50.000000000 +0800
> @@ -13,6 +13,7 @@ typedef u32 kprobe_opcode_t;
>  
>  #define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
>  #define arch_remove_kprobe(p)	do {} while (0)
> +#define flush_insn_slot(p)	do { } while (0)
>  
>  /* Architecture specific copy of original instruction*/
>  struct arch_specific_insn {
> diff -Nruap 2.6.17.org/include/asm-x86_64/kprobes.h 2.6.17/include/asm-x86_64/kprobes.h
> --- 2.6.17.org/include/asm-x86_64/kprobes.h	2006-03-27 14:41:23.000000000 +0800
> +++ 2.6.17/include/asm-x86_64/kprobes.h	2006-06-30 02:32:05.000000000 +0800
> @@ -43,6 +43,7 @@ typedef u8 kprobe_opcode_t;
>  
>  #define JPROBE_ENTRY(pentry)	(kprobe_opcode_t *)pentry
>  #define ARCH_SUPPORTS_KRETPROBES
> +#define flush_insn_slot(p)	do { } while (0)
>  
>  void kretprobe_trampoline(void);
>  extern void arch_remove_kprobe(struct kprobe *p);
> diff -Nruap 2.6.17.org/kernel/kprobes.c 2.6.17/kernel/kprobes.c
> --- 2.6.17.org/kernel/kprobes.c	2006-06-29 03:50:19.000000000 +0800
> +++ 2.6.17/kernel/kprobes.c	2006-06-30 02:23:51.000000000 +0800
> @@ -420,6 +420,7 @@ static int __kprobes register_aggr_kprob
>  		add_aggr_kprobe(ap, old_p);
>  		copy_kprobe(ap, p);
>  		ret = add_new_kprobe(ap, p);
> +		flush_insn_slot(ap);
Same here..you need to flush_insn_slot(ap) before add_new_kprobe(ap, p).
>  	}
>  	return ret;
>  }
