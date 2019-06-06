From: Matthias Schiffer <matthias.schiffer@ew.tq-group.com>
Date: Thu, 06 Jun 2019 08:14:44 +0000
Subject: Re: [PATCH modules 0/2] Fix handling of exit unwinding sections (on ARM)
Message-Id: <61f233518ba863f9d5783dd10e468ee5bf22b69a.camel@ew.tq-group.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
In-Reply-To: <20190603105726.22436-1-matthias.schiffer@ew.tq-group.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King <linux@armlinux.org.uk>, Jessica Yu <jeyu@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 2019-06-03 at 12:57 +0200, Matthias Schiffer wrote:
> For some time (050d18d1c651 "ARM: 8650/1: module: handle negative
> R_ARM_PREL31 addends correctly", v4.11+), building a kernel without
> CONFIG_MODULE_UNLOAD would lead to module loads failing on ARM
> systems with
> certain memory layouts, with messages like:
> 
>   imx_sdma: section 16 reloc 0 sym '': relocation 42 out of range
>   (0x7f015260 -> 0xc0f5a5e8)
> 
> (0x7f015260 is in the module load area, 0xc0f5a5e8 a regular vmalloc
> address; relocation 42 is R_ARM_PREL31)
> 
> This is caused by relocatiosn in the .ARM.extab.exit.text and
> .ARM.exidx.exit.text sections referencing the .exit.text section. As
> the
> module loader will omit loading .exit.text without
> CONFIG_MODULE_UNLOAD,
> there will be relocations from loaded to unloaded sections; the
> resulting
> huge offsets trigger the sanity checks added in 050d18d1c651.
> 
> IA64 might be affected by a similar issue - sections with names like
> .IA_64.unwind.exit.text and .IA_64.unwind_info.exit.text appear in
> the ld
> script - but I don't know much about that arch.
> 
> Also, I'm not sure if this is stable-worthy - just enabling
> CONFIG_MODULE_UNLOAD should be a viable workaround on affected
> kernels.
> 
> 
> Kind regards,
> Matthias


Hi,
any comments on these patches? If not, who is going to take them in
their tree?

Note that I'll be out of office for the next week, and I won't be able
to read my mail during this period.


Kind regards,
Matthias




> 
> 
> Matthias Schiffer (2):
>   module: allow arch overrides for .exit section names
>   ARM: module: recognize unwind exit sections
> 
>  arch/arm/include/asm/module.h | 11 +++++++++++
>  include/linux/moduleloader.h  |  8 ++++++++
>  kernel/module.c               |  2 +-
>  3 files changed, 20 insertions(+), 1 deletion(-)
> 
