From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Sun, 25 Jun 2017 03:26:21 +0000
Subject: Re: [PATCH v2 2/3] ia64: thin archives fix linking
Message-Id: <CAK7LNAQhf8Lvyc93gQXw985XTtg165eE9Af-C=RR-b5r_x_R1g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170622123929.15054-1-npiggin@gmail.com> <20170622123929.15054-3-npiggin@gmail.com>
 <CAK7LNATX=Mvu1PtHQOnkwr2D9wc4cFJEOoTPgOK2t=026i8OKg@mail.gmail.com> <20170623234415.7d493a8d@roar.ozlabs.ibm.com>
In-Reply-To: <20170623234415.7d493a8d@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

2017-06-23 22:44 GMT+09:00 Nicholas Piggin <npiggin@gmail.com>:
> On Fri, 23 Jun 2017 18:56:32 +0900
> Masahiro Yamada <yamada.masahiro@socionext.com> wrote:
>
>> Hi Nicholas,
>>
>>
>> 2017-06-22 21:39 GMT+09:00 Nicholas Piggin <npiggin@gmail.com>:
>
>
>> Without this patch,
>>
>> $ ia64-linux-nm -n arch/ia64/kernel/gate-syms.o
>> a000000000000600 D __start_gate_mckinley_e9_patchlist
>> a000000000000604 D __end_gate_mckinley_e9_patchlist
>> a000000000000604 D __end_gate_vtop_patchlist
>> a000000000000604 D __start_gate_fsyscall_patchlist
>> a000000000000604 D __start_gate_vtop_patchlist
>> a000000000000608 D __end_gate_fsyscall_patchlist
>> a000000000000608 D __start_gate_brl_fsys_bubble_down_patchlist
>> a00000000000060c D __end_gate_brl_fsys_bubble_down_patchlist
>> a000000000040720 T __kernel_syscall_via_break
>> a000000000040740 T __kernel_sigtramp
>> a000000000040770 t back_from_setup_rbs
>> a000000000040830 t back_from_restore_rbs
>> a0000000000408a0 t setup_rbs
>> a000000000040900 t restore_rbs
>> a000000000040a00 T __kernel_syscall_via_epc
>>
>> $ ia64-linux-nm -n arch/ia64/kernel/built-in.o | grep  __kernel_sigtramp
>> a000000000040740 A __kernel_sigtramp
>>
>>
>> With this patch,
>>
>> $ ia64-linux-nm -n arch/ia64/kernel/gate-syms.o
>> 0000000000000000 A __kernel_syscall_via_break
>
>> 0000000000000020 A __kernel_sigtramp
>> 00000000000002e0 A __kernel_syscall_via_epc
>> a000000000000600 D __end_gate_brl_fsys_bubble_down_patchlist
>> a000000000000600 D __end_gate_fsyscall_patchlist
>> a000000000000600 D __end_gate_mckinley_e9_patchlist
>> a000000000000600 D __end_gate_vtop_patchlist
>> a000000000000600 D __start_gate_brl_fsys_bubble_down_patchlist
>> a000000000000600 D __start_gate_fsyscall_patchlist
>> a000000000000600 D __start_gate_mckinley_e9_patchlist
>> a000000000000600 D __start_gate_vtop_patchlist
>>
>> $ ia64-linux-nm -n arch/ia64/kernel/built-in.o | grep __kernel_sigtramp
>> 0000000000000020 A __kernel_sigtramp
>>
>>
>> Could you check it?
>
> Sorry about this, thank you for catching it.
>
> This needs a dummy .o file as well. It seems we cannot do both -T and -R
> operations in one step. This patch follows more like sh and tile fixes.
>
> Thanks,
> Nick
>
> ---
>  arch/ia64/kernel/Makefile.gate | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
>
> diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
> index a32903ada016..e8ca862e7b21 100644
> --- a/arch/ia64/kernel/Makefile.gate
> +++ b/arch/ia64/kernel/Makefile.gate
> @@ -1,8 +1,10 @@
>  # The gate DSO image is built using a special linker script.
>
> -targets += gate.so gate-syms.o
> +targets += gate.so gate-syms.o gate-dummy.o
>
> -extra-y += gate.so gate-syms.o gate.lds gate.o
> +obj-y += gate-syms.o
> +
> +extra-y += gate.so gate.lds gate.o
>
>  CPPFLAGS_gate.lds := -P -C -U$(ARCH)
>
> @@ -14,13 +16,17 @@ GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
>  $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE
>         $(call if_changed,gate)
>
> -$(obj)/built-in.o: $(obj)/gate-syms.o
> -$(obj)/built-in.o: ld_flags += -R $(obj)/gate-syms.o
> +# create an object file to resolve gate symbols
> +quiet_cmd_gate_syms = GATESYM $@
> +      cmd_gate_syms = $(LD) -r -R $(obj)/gate-dummy.o -o $@
>
> -GATECFLAGS_gate-syms.o = -r
> -$(obj)/gate-syms.o: $(obj)/gate.lds $(obj)/gate.o FORCE
> +GATECFLAGS_gate-dummy.o = -r
> +$(obj)/gate-dummy.o: $(obj)/gate.lds $(obj)/gate.o FORCE
>         $(call if_changed,gate)
>
> +$(obj)/gate-syms.o: $(obj)/gate-dummy.o FORCE
> +       $(call if_changed,gate_syms)
> +
>  # gate-data.o contains the gate DSO image as data in section .data..gate.
>  # We must build gate.so before we can assemble it.
>  # Note: kbuild does not track this dependency due to usage of .incbin
> --


I replaced the patch.  Thanks!


I locally changed to the following part to not repeat gate-dummy.o





diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
index e8ca862..8cd125a 100644
--- a/arch/ia64/kernel/Makefile.gate
+++ b/arch/ia64/kernel/Makefile.gate
@@ -18,7 +18,7 @@ $(obj)/gate.so: $(obj)/gate.lds $(obj)/gate.o FORCE

 # create an object file to resolve gate symbols
 quiet_cmd_gate_syms = GATESYM $@
-      cmd_gate_syms = $(LD) -r -R $(obj)/gate-dummy.o -o $@
+      cmd_gate_syms = $(LD) -r -o $@ -R $<

 GATECFLAGS_gate-dummy.o = -r
 $(obj)/gate-dummy.o: $(obj)/gate.lds $(obj)/gate.o FORCE




-- 
Best Regards
Masahiro Yamada
