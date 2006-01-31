From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 31 Jan 2006 17:39:48 +0000
Subject: Re: [patch 5/6] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <ed5aea430601310939mb4ac2d8wb25c05baf11584cd@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
In-Reply-To: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Ken,

To be safe, I think you need to default to the maximum number of
physical stacked registers (which is somewhere around 16,384, based on
the width of the ARC.RSC.LOADRS field).  Also, did you verify that the
patching is indeed atomic (we just modify a few bits, so we're
*probably* OK, but it needs to be verified that the bits we modify
don't straddle a word-boundary)?

Thanks,

  --david

On 1/31/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> It's not very efficient to use a per-cpu variable just to store
> how many physical stack register a cpu has.  Ever since the
> incarnation of ia64 up till upcoming Montecito processor, that
> variable has "glued" to 96. Having a variable in memory means
> that the kernel is burning an extra cacheline access on every
> syscall and kernel exit path.  Such "static" value is better
> served with the instruction patching utility exists today.
> Convert ia64_phys_stacked_size_p8 into dynamic insn patching.
>
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
>
>
> --- ./arch/ia64/kernel/entry.S.orig     2006-01-31 01:10:56.418929282 -08=
00
> +++ ./arch/ia64/kernel/entry.S  2006-01-31 01:11:38.261702207 -0800
> @@ -773,7 +773,7 @@ ENTRY(ia64_leave_syscall)
>         ld8.fill r15=3D[r3]                       // M0|1 restore r15
>         mov b6=3Dr18                              // I0   restore b6
>
> -       addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0 // A
> +       LOAD_PHYS_STACK_REG_SIZE(r17)
>         mov f9=F0                                       // F    clear f9
>  (pKStk) br.cond.dpnt.many skip_rbs_switch              // B
>
> @@ -781,7 +781,6 @@ ENTRY(ia64_leave_syscall)
>         shr.u r18=3Dr19,16                // I0|1 get byte size of existi=
ng "dirty" partition
>         cover                           // B    add current frame into di=
rty partition & set cr.ifs
>         ;;
> -(pUStk) ld4 r17=3D[r17]                  // M0|1 r17 =3D cpu_data->phys_=
stacked_size_p8
>         mov r19=3Dar.bsp                  // M2   get new backing store p=
ointer
>         mov f10=F0                      // F    clear f10
>
> @@ -972,10 +971,8 @@ GLOBAL_ENTRY(ia64_leave_kernel)
>         ld8.fill r3=3D[r16]
>  (pUStk)        st1 [r18]=3Dr17           // restore current->thread.on_u=
stack
>         shr.u r18=3Dr19,16        // get byte size of existing "dirty" pa=
rtition
> -       ;;
> -       addl r17=3DTHIS_CPU(ia64_phys_stacked_size_p8),r0
> -       ;;
> -       ld4 r17=3D[r17]           // r17 =3D cpu_data->phys_stacked_size_=
p8
> +
> +       LOAD_PHYS_STACK_REG_SIZE(r17)
>  (pKStk)        br.cond.dpnt skip_rbs_switch
>
>  rbs_switch:
> --- ./arch/ia64/kernel/vmlinux.lds.S.orig       2006-01-02 19:21:10.00000=
0000 -0800
> +++ ./arch/ia64/kernel/vmlinux.lds.S    2006-01-31 01:11:38.261702207 -08=
00
> @@ -84,6 +84,13 @@ SECTIONS
>           __end___mckinley_e9_bundles =3D .;
>         }
>
> +  .data.patch.phys_stack_reg : AT(ADDR(.data.patch.phys_stack_reg) - LOA=
D_OFFSET)
> +       {
> +         __start___phys_stack_reg_patchlist =3D .;
> +         *(.data.patch.phys_stack_reg)
> +         __end___phys_stack_reg_patchlist =3D .;
> +       }
> +
>    /* Global data */
>    _data =3D .;
>
> --- ./arch/ia64/kernel/setup.c.orig     2006-01-02 19:21:10.000000000 -08=
00
> +++ ./arch/ia64/kernel/setup.c  2006-01-31 01:11:38.262678769 -0800
> @@ -71,7 +71,6 @@ EXPORT_SYMBOL(__per_cpu_offset);
>
>  DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
>  DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
> -DEFINE_PER_CPU(unsigned long, ia64_phys_stacked_size_p8);
>  unsigned long ia64_cycles_per_usec;
>  struct ia64_boot_param *ia64_boot_param;
>  struct screen_info screen_info;
> @@ -746,6 +745,7 @@ void
>  cpu_init (void)
>  {
>         extern void __devinit ia64_mmu_init (void *);
> +       static unsigned long max_num_phys_stacked =3D IA64_NUM_PHYS_STACK=
_REG;
>         unsigned long num_phys_stacked;
>         pal_vm_info_2_u_t vmi;
>         unsigned int max_ctx;
> @@ -859,7 +859,10 @@ cpu_init (void)
>                 num_phys_stacked =3D 96;
>         }
>         /* size of physical stacked register partition plus 8 bytes: */
> -       __get_cpu_var(ia64_phys_stacked_size_p8) =3D num_phys_stacked*8 +=
 8;
> +       if (num_phys_stacked > max_num_phys_stacked) {
> +               ia64_patch_phys_stack_reg(num_phys_stacked*8 + 8);
> +               max_num_phys_stacked =3D num_phys_stacked;
> +       }
>         platform_cpu_init();
>         pm_idle =3D default_idle;
>  }
> --- ./arch/ia64/kernel/patch.c.orig     2006-01-02 19:21:10.000000000 -08=
00
> +++ ./arch/ia64/kernel/patch.c  2006-01-31 01:12:02.014631603 -0800
> @@ -195,3 +195,23 @@ ia64_patch_gate (void)
>         ia64_patch_vtop(START(vtop), END(vtop));
>         ia64_patch_mckinley_e9(START(mckinley_e9), END(mckinley_e9));
>  }
> +
> +void ia64_patch_phys_stack_reg(unsigned long val)
> +{
> +       s32 * offp =3D (s32 *) __start___phys_stack_reg_patchlist;
> +       s32 * end =3D (s32 *) __end___phys_stack_reg_patchlist;
> +       u64 ip, mask, imm;
> +
> +       /* see instruction format A4: adds r1 =3D imm13, r3 */
> +       mask =3D (0x3fUL << 27) | (0x7f << 13);
> +       imm =3D (((val >> 7) & 0x3f) << 27) | (val & 0x7f) << 13;
> +
> +       while (offp < end) {
> +               ip =3D (u64) offp + *offp;
> +               ia64_patch(ip, mask, imm);
> +               ia64_fc(ip);
> +               ++offp;
> +       }
> +       ia64_sync_i();
> +       ia64_srlz_i();
> +}
> --- ./include/asm-ia64/processor.h.orig 2006-01-02 19:21:10.000000000 -08=
00
> +++ ./include/asm-ia64/processor.h      2006-01-31 01:11:38.263655332 -08=
00
> @@ -20,6 +20,7 @@
>  #include <asm/ptrace.h>
>  #include <asm/ustack.h>
>
> +#define IA64_NUM_PHYS_STACK_REG        96
>  #define IA64_NUM_DBG_REGS      8
>  /*
>   * Limits for PMC and PMD are set to less than maximum architected values
> --- ./include/asm-ia64/asmmacro.h.orig  2006-01-02 19:21:10.000000000 -08=
00
> +++ ./include/asm-ia64/asmmacro.h       2006-01-31 01:11:38.263655332 -08=
00
> @@ -90,6 +90,16 @@ name:
>  #endif
>
>  /*
> + * If physical stack register size is different from DEF_NUM_STACK_REG,
> + * dynamically patch the kernel for correct size.
> + */
> +       .section ".data.patch.phys_stack_reg", "a"
> +       .previous
> +#define LOAD_PHYS_STACK_REG_SIZE(reg)                  \
> +[1:]   adds reg=3DIA64_NUM_PHYS_STACK_REG*8+8,r0;        \
> +       .xdata4 ".data.patch.phys_stack_reg", 1b-.
> +
> +/*
>   * Up until early 2004, use of .align within a function caused bad unwin=
d info.
>   * TEXT_ALIGN(n) expands into ".align n" if a fixed GAS is available or =
into nothing
>   * otherwise.
> --- ./include/asm-ia64/patch.h.orig     2006-01-02 19:21:10.000000000 -08=
00
> +++ ./include/asm-ia64/patch.h  2006-01-31 01:11:38.264631894 -0800
> @@ -20,6 +20,7 @@ extern void ia64_patch_imm60 (u64 insn_a
>
>  extern void ia64_patch_mckinley_e9 (unsigned long start, unsigned long e=
nd);
>  extern void ia64_patch_vtop (unsigned long start, unsigned long end);
> +extern void ia64_patch_phys_stack_reg(unsigned long val);
>  extern void ia64_patch_gate (void);
>
>  #endif /* _ASM_IA64_PATCH_H */
> --- ./include/asm-ia64/sections.h.orig  2006-01-02 19:21:10.000000000 -08=
00
> +++ ./include/asm-ia64/sections.h       2006-01-31 01:11:38.264631894 -08=
00
> @@ -11,6 +11,7 @@
>  extern char __per_cpu_start[], __per_cpu_end[], __phys_per_cpu_start[];
>  extern char __start___vtop_patchlist[], __end___vtop_patchlist[];
>  extern char __start___mckinley_e9_bundles[], __end___mckinley_e9_bundles=
[];
> +extern char __start___phys_stack_reg_patchlist[], __end___phys_stack_reg=
_patchlist[];
>  extern char __start_gate_section[];
>  extern char __start_gate_mckinley_e9_patchlist[], __end_gate_mckinley_e9=
_patchlist[];
>  extern char __start_gate_vtop_patchlist[], __end_gate_vtop_patchlist[];
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
