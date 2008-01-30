From: Mike Travis <travis@sgi.com>
Date: Wed, 30 Jan 2008 18:41:26 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <47A0C4D6.4000100@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

Luck, Tony wrote:
>> Could you check the patch below? With this applied to latest -git, ia64 
>> buils fine for me in a cross-compiling environment. (but i dont know 
>> whether it boots ...)
> 
> Uni-processor build still fails with this patch (config is arch/ia64/configs/tiger_defconfig
> with CONFIG_SMP switched from =y to =n).

I'll add an ia64-nosmp config to our cross build test environment and fix this up...

Thanks,
Mike

> 
> arch/ia64/kernel/built-in.o(.text+0x5012): In function `show_interrupts':
> : relocation truncated to fit: IMM22 per_cpu__kstat
> arch/ia64/kernel/built-in.o(.text+0x53e1): In function `__bind_irq_vector':
> : relocation truncated to fit: IMM22 per_cpu__vector_irq
> arch/ia64/kernel/built-in.o(.text+0x5612): In function `__clear_irq_vector':
> : relocation truncated to fit: IMM22 per_cpu__vector_irq
> arch/ia64/kernel/built-in.o(.text+0x5a81): In function `__setup_vector_irq':
> : relocation truncated to fit: IMM22 per_cpu__vector_irq
> arch/ia64/kernel/built-in.o(.text+0x6231): In function `ia64_handle_irq':
> : relocation truncated to fit: IMM22 per_cpu____irq_regs
> arch/ia64/kernel/built-in.o(.text+0x6272): In function `ia64_handle_irq':
> : relocation truncated to fit: IMM22 per_cpu__vector_irq
> arch/ia64/kernel/built-in.o(.text+0x7b81): In function `cpu_idle_wait':
> : relocation truncated to fit: IMM22 .text
> arch/ia64/kernel/built-in.o(.text+0x7e21): In function `cpu_idle':
> : relocation truncated to fit: IMM22 .text
> arch/ia64/kernel/built-in.o(.text+0x7fd1): In function `ia64_save_extra':
> : relocation truncated to fit: IMM22 per_cpu__pfm_syst_info
> arch/ia64/kernel/built-in.o(.text+0x8071): In function `ia64_load_extra':
> : relocation truncated to fit: IMM22 per_cpu__pfm_syst_info
> arch/ia64/kernel/built-in.o(.text+0x95c0): In function `pfm_write_ibr_dbr':
> : additional relocation overflows omitted from the output
> ld: final link failed: Nonrepresentable section on output
> make: *** [.tmp_vmlinux1] Error 1
> 
> SMP build (config zx1_defconfig) builds ok and boots ok too.
> 
> -Tony

