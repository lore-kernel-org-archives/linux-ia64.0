From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 23 Jun 2017 09:56:32 +0000
Subject: Re: [PATCH v2 2/3] ia64: thin archives fix linking
Message-Id: <CAK7LNATX=Mvu1PtHQOnkwr2D9wc4cFJEOoTPgOK2t=026i8OKg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170622123929.15054-1-npiggin@gmail.com> <20170622123929.15054-3-npiggin@gmail.com>
In-Reply-To: <20170622123929.15054-3-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Hi Nicholas,


2017-06-22 21:39 GMT+09:00 Nicholas Piggin <npiggin@gmail.com>:
> The VDSO symbols can't be linked into built-in.o when building with
> thin archives, so change this to linking a new object file that is
> included into the built-in.o.
>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  arch/ia64/kernel/Makefile.gate | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
> index a32903ada016..e20c711c2b1e 100644
> --- a/arch/ia64/kernel/Makefile.gate
> +++ b/arch/ia64/kernel/Makefile.gate
> @@ -2,7 +2,9 @@
>
>  targets += gate.so gate-syms.o
>
> -extra-y += gate.so gate-syms.o gate.lds gate.o
> +obj-y += gate-syms.o
> +
> +extra-y += gate.so gate.lds gate.o
>
>  CPPFLAGS_gate.lds := -P -C -U$(ARCH)
>
> @@ -14,12 +16,12 @@ GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
>  $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
>         $(call if_changed,gate)
>
> -$(obj)/built-in.o: $(obj)/gate-syms.o
> -$(obj)/built-in.o: ld_flags += -R $(obj)/gate-syms.o
> +# create an object file to resolve gate symbols
> +quiet_cmd_gate_syms = GATESYM $@
> +      cmd_gate_syms = $(LD) -r -T $(obj)/gate.lds -R $(obj)/gate.o -o $@
>
> -GATECFLAGS_gate-syms.o = -r
>  $(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
> -       $(call if_changed,gate)
> +       $(call if_changed,gate_syms)
>
>  # gate-data.o contains the gate DSO image as data in section .data..gate.
>  # We must build gate.so before we can assemble it.
> --
> 2.11.0


Build test passed, but the symbol table seems different.

For example,  __kernel_sigtramp will change
a000000000040740 T __kernel_sigtramp
 to
0000000000000020 A __kernel_sigtramp






Without this patch,

$ ia64-linux-nm -n arch/ia64/kernel/gate-syms.o
a000000000000600 D __start_gate_mckinley_e9_patchlist
a000000000000604 D __end_gate_mckinley_e9_patchlist
a000000000000604 D __end_gate_vtop_patchlist
a000000000000604 D __start_gate_fsyscall_patchlist
a000000000000604 D __start_gate_vtop_patchlist
a000000000000608 D __end_gate_fsyscall_patchlist
a000000000000608 D __start_gate_brl_fsys_bubble_down_patchlist
a00000000000060c D __end_gate_brl_fsys_bubble_down_patchlist
a000000000040720 T __kernel_syscall_via_break
a000000000040740 T __kernel_sigtramp
a000000000040770 t back_from_setup_rbs
a000000000040830 t back_from_restore_rbs
a0000000000408a0 t setup_rbs
a000000000040900 t restore_rbs
a000000000040a00 T __kernel_syscall_via_epc

$ ia64-linux-nm -n arch/ia64/kernel/built-in.o | grep  __kernel_sigtramp
a000000000040740 A __kernel_sigtramp


With this patch,

$ ia64-linux-nm -n arch/ia64/kernel/gate-syms.o
0000000000000000 A __kernel_syscall_via_break
0000000000000020 A __kernel_sigtramp
00000000000002e0 A __kernel_syscall_via_epc
a000000000000600 D __end_gate_brl_fsys_bubble_down_patchlist
a000000000000600 D __end_gate_fsyscall_patchlist
a000000000000600 D __end_gate_mckinley_e9_patchlist
a000000000000600 D __end_gate_vtop_patchlist
a000000000000600 D __start_gate_brl_fsys_bubble_down_patchlist
a000000000000600 D __start_gate_fsyscall_patchlist
a000000000000600 D __start_gate_mckinley_e9_patchlist
a000000000000600 D __start_gate_vtop_patchlist

$ ia64-linux-nm -n arch/ia64/kernel/built-in.o | grep __kernel_sigtramp
0000000000000020 A __kernel_sigtramp


Could you check it?




-- 
Best Regards
Masahiro Yamada
