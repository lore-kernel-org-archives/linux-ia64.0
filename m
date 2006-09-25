From: "bibo,mao" <bibo.mao@intel.com>
Date: Mon, 25 Sep 2006 09:31:47 +0000
Subject: Re: [PATCH] kprobe opcode 16 bytes alignment on IA64
Message-Id: <4517A203.7050601@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158822808.2718.43.camel@linux-znh>
In-Reply-To: <1158822808.2718.43.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zou, Nanhai wrote:
> On Thu, 2006-09-21 at 15:31, bibo,mao wrote:
>  > Hi,
>  >   On IA64 instruction opcode must be 16 bytes alignment, in kprobe
>  > structure there is one element to save original instruction, currently
>  > saved opcode is not statically allocated in kprobe structure, that can
>  > not assure 16 bytes alignment. This patch dynamically allocated kprobe
>  > instruction opcode to assure 16 bytes alignment.
>  >
>  > signed-off-by: bibo mao <bibo.mao@intel.com>
>  >
>  > thanks
>  > bibo,mao
>  >
>  > diff --git a/arch/ia64/kernel/kprobes.c b/arch/ia64/kernel/kprobes.c
>  > index 781960f..e6cf5d4 100644
>  > --- a/arch/ia64/kernel/kprobes.c
>  > +++ b/arch/ia64/kernel/kprobes.c
>  > @@ -136,10 +136,8 @@ static void __kprobes update_kprobe_inst
>  >  static int __kprobes unsupported_inst(uint template, uint  slot,
>  >                                       uint major_opcode,
>  >                                       unsigned long kprobe_inst,
>  > -                                     struct kprobe *p)
>  > +                                     unsigned long addr)
>  >  {
>  > -       unsigned long addr = (unsigned long)p->addr;
>  > -
>  >         if (bundle_encoding[template][slot] = I) {
>  >                 switch (major_opcode) {
>  >                         case 0x0: //I_UNIT_MISC_OPCODE:
>  > @@ -217,7 +215,7 @@ static void __kprobes prepare_break_inst
>  >                                          struct kprobe *p)
>  >  {
>  >         unsigned long break_inst = BREAK_INST;
>  > -       bundle_t *bundle = &p->ainsn.insn.bundle;
>  > +       bundle_t *bundle = &p->opcode.bundle;
>  > 
>  >         /*
>  >          * Copy the original kprobe_inst qualifying predicate(qp)
>  > @@ -423,11 +421,9 @@ int __kprobes arch_prepare_kprobe(struct
>  >         unsigned long *kprobe_addr = (unsigned long *)(addr &
>  > ~0xFULL);
>  >         unsigned long kprobe_inst=0;
>  >         unsigned int slot = addr & 0xf, template, major_opcode = 0;
>  > -       bundle_t *bundle = &p->ainsn.insn.bundle;
>  > -
>  > -       memcpy(&p->opcode.bundle, kprobe_addr, sizeof(bundle_t));
>  > -       memcpy(&p->ainsn.insn.bundle, kprobe_addr, sizeof(bundle_t));
>  > +       bundle_t *bundle;
>  > 
>  > +       bundle = &((kprobe_opcode_t *)kprobe_addr)->bundle;
>  >         template = bundle->quad0.template;
>  > 
>  >         if(valid_kprobe_addr(template, slot, addr))
>  > @@ -440,20 +436,19 @@ int __kprobes arch_prepare_kprobe(struct
>  >         /* Get kprobe_inst and major_opcode from the bundle */
>  >         get_kprobe_inst(bundle, slot, &kprobe_inst, &major_opcode);
>  > 
>  > -       if (unsupported_inst(template, slot, major_opcode,
>  > kprobe_inst, p))
>  > +       if (unsupported_inst(template, slot, major_opcode,
>  > kprobe_inst, addr))
>  >                         return -EINVAL;
>  > 
>  > -       prepare_break_inst(template, slot, major_opcode, kprobe_inst,
>  > p);
>  > 
>  > -       return 0;
>  > -}
>  > +       p->ainsn.insn = get_insn_slot();
>  > +       if (!p->ainsn.insn)
>  > +               return -ENOMEM;
>  > +       memcpy(&p->opcode, kprobe_addr, sizeof(kprobe_opcode_t));
>  > +       memcpy(p->ainsn.insn, kprobe_addr, sizeof(kprobe_opcode_t));
>  > 
>  > -void __kprobes flush_insn_slot(struct kprobe *p)
>  > -{
>  > -       unsigned long arm_addr;
>  > +       prepare_break_inst(template, slot, major_opcode, kprobe_inst,
>  > p);
>  > 
>  > -       arm_addr = ((unsigned long)&p->opcode.bundle) & ~0xFULL;
>  > -       flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
>  > +       return 0;
>  >  }
>  > 
>  >  void __kprobes arch_arm_kprobe(struct kprobe *p)
>  > @@ -461,9 +456,10 @@ void __kprobes arch_arm_kprobe(struct kp
>  >         unsigned long addr = (unsigned long)p->addr;
>  >         unsigned long arm_addr = addr & ~0xFULL;
>  > 
>  > -       flush_insn_slot(p);
>  > -       memcpy((char *)arm_addr, &p->ainsn.insn.bundle,
>  > sizeof(bundle_t));
>  > -       flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
>  > +       flush_icache_range((unsigned long)p->ainsn.insn,
>  > +                       (unsigned long)p->ainsn.insn +
>  > sizeof(kprobe_opcode_t));
>  > +       memcpy((char *)arm_addr, &p->opcode, sizeof(kprobe_opcode_t));
>  > +       flush_icache_range(arm_addr, arm_addr +
>  > sizeof(kprobe_opcode_t));
>  >  }
>  > 
>  >  void __kprobes arch_disarm_kprobe(struct kprobe *p)
>  > @@ -471,11 +467,18 @@ void __kprobes arch_disarm_kprobe(struct
>  >         unsigned long addr = (unsigned long)p->addr;
>  >         unsigned long arm_addr = addr & ~0xFULL;
>  > 
>  > -       /* p->opcode contains the original unaltered bundle */
>  > -       memcpy((char *) arm_addr, (char *) &p->opcode.bundle,
>  > sizeof(bundle_t));
>  > -       flush_icache_range(arm_addr, arm_addr + sizeof(bundle_t));
>  > +       /* p->ainsn.insn contains the original unaltered
>  > kprobe_opcode_t */
>  > +       memcpy((char *) arm_addr, (char *) p->ainsn.insn,
>  > +                                        sizeof(kprobe_opcode_t));
>  > +       flush_icache_range(arm_addr, arm_addr +
>  > sizeof(kprobe_opcode_t));
>  >  }
>  > 
>  > +void __kprobes arch_remove_kprobe(struct kprobe *p)
>  > +{
>  > +       mutex_lock(&kprobe_mutex);
>  > +       free_insn_slot(p->ainsn.insn);
>  > +       mutex_unlock(&kprobe_mutex);
>  > +}
>  >  /*
>  >   * We are resuming execution after a single step fault, so the
>  > pt_regs
>  >   * structure reflects the register state after we executed the
>  > instruction
>  > @@ -486,12 +489,12 @@ void __kprobes arch_disarm_kprobe(struct
>  >   */
>  >  static void __kprobes resume_execution(struct kprobe *p, struct
>  > pt_regs *regs)
>  >  {
>  > -       unsigned long bundle_addr = ((unsigned long)
>  > (&p->opcode.bundle)) & ~0xFULL;
>  > +       unsigned long bundle_addr = (unsigned long)
>  > (&p->ainsn.insn->bundle);
>  >         unsigned long resume_addr = (unsigned long)p->addr & ~0xFULL;
>  >         unsigned long template;
>  >         int slot = ((unsigned long)p->addr & 0xf);
>  > 
>  > -       template = p->opcode.bundle.quad0.template;
>  > +       template = p->ainsn.insn->bundle.quad0.template;
>  > 
>  >         if (slot = 1 && bundle_encoding[template][1] = L)
>  >                 slot = 2;
>  > @@ -553,7 +556,7 @@ turn_ss_off:
>  > 
>  >  static void __kprobes prepare_ss(struct kprobe *p, struct pt_regs
>  > *regs)
>  >  {
>  > -       unsigned long bundle_addr = (unsigned long) &p->opcode.bundle;
>  > +       unsigned long bundle_addr = (unsigned long)
>  > &p->ainsn.insn->bundle;
>  >         unsigned long slot = (unsigned long)p->addr & 0xf;
>  > 
>  >         /* single step inline if break instruction */
>  > diff --git a/include/asm-i386/kprobes.h b/include/asm-i386/kprobes.h
>  > diff --git a/include/asm-ia64/kprobes.h b/include/asm-ia64/kprobes.h
>  > index 9389049..1b45b71 100644
>  > --- a/include/asm-ia64/kprobes.h
>  > +++ b/include/asm-ia64/kprobes.h
>  > @@ -29,7 +29,8 @@ #include <linux/ptrace.h>
>  >  #include <linux/percpu.h>
>  >  #include <asm/break.h>
>  > 
>  > -#define MAX_INSN_SIZE   16
>  > +#define __ARCH_WANT_KPROBES_INSN_SLOT
>  > +#define MAX_INSN_SIZE   1
>  >  #define BREAK_INST     (long)(__IA64_BREAK_KPROBE << 6)
>  > 
>  >  typedef union cmp_inst {
>  > @@ -94,7 +95,7 @@ #define IP_RELATIVE_BRANCH_OPCODE     (4)
>  >  #define IP_RELATIVE_PREDICT_OPCODE     (7)
>  >  #define LONG_BRANCH_OPCODE             (0xC)
>  >  #define LONG_CALL_OPCODE               (0xD)
>  > -#define arch_remove_kprobe(p)          do {} while (0)
>  > +#define flush_insn_slot(p)             do { } while (0)
>  > 
>  >  typedef struct kprobe_opcode {
>  >         bundle_t bundle;
>  > @@ -108,7 +109,7 @@ struct fnptr {
>  >  /* Architecture specific copy of original instruction*/
>  >  struct arch_specific_insn {
>  >         /* copy of the instruction to be emulated */
>  > -       kprobe_opcode_t insn;
>  > +       kprobe_opcode_t *insn;
>  >   #define INST_FLAG_FIX_RELATIVE_IP_ADDR                1
>  >   #define INST_FLAG_FIX_BRANCH_REG              2
>  >   #define INST_FLAG_BREAK_INST                  4
>  > @@ -125,6 +126,6 @@ static inline void jprobe_return(void)
>  >  }
>  >  extern void invalidate_stacked_regs(void);
>  >  extern void flush_register_stack(void);
>  > -extern void flush_insn_slot(struct kprobe *p);
>  > +extern void arch_remove_kprobe(struct kprobe *p);
>  > 
>  >  #endif                         /* _ASM_KPROBES_H */
>  > -
>   I think it is DEBUG_SLAB that breaks the nature alignment of the
> kmalloced area.
>   On a system without DEBUG_SLAB, ARCH_KMALLOC_MINALIGN is 128, and
> bundle_t is declared as __aligned__(16);. It is impossible to see insn
> aligned to a 8 byte boundary.
> 
>   But with DEBUG_SLAB enabled, ARCH_KMALLOC_MINALIGN may shrink to 8
> bytes.
yes, in my kernel configuration DEBUG_SLAB is enabled so that memory address
is not 16 bytes alignment. I think that kmalloc function has no problem, so here
in my patch kprobe opcode is dynamically allocated so that it is 16 bytes
alignment.

thanks
bibo,mao

> 
>   Thanks
>   Zou Nan hai  
> 
