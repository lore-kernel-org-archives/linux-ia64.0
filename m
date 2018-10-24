From: Rob Herring <robh@kernel.org>
Date: Wed, 24 Oct 2018 19:55:17 +0000
Subject: Re: [PATCH v2 0/2] arm64: Cut rebuild time when changing CONFIG_BLK_DEV_INITRD
Message-Id: <CAL_Jsq+KCOv6pXXHhHDZ+7-QUrmtMDvSjEVhK15yZ3qbnn61Ag@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181024193256.23734-1-f.fainelli@gmail.com>
In-Reply-To: <20181024193256.23734-1-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Marc Zyngier <marc.zyngier@arm.com>, Olof Johansson <olof@lixom.net>, linux-alpha@vger.kernel.org, arcml <linux-snps-arc@lists.infradead.org>, "moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, linux-c6x-dev@linux-c6x.org, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Linux-MIPS <linux-mips@linux-mips.org>, nios2-dev@lists.rocketboards.org, Openrisc <openrisc@list>

On Wed, Oct 24, 2018 at 2:33 PM Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> Hi all,
>
> While investigating why ARM64 required a ton of objects to be rebuilt
> when toggling CONFIG_DEV_BLK_INITRD, it became clear that this was
> because we define __early_init_dt_declare_initrd() differently and we do
> that in arch/arm64/include/asm/memory.h which gets included by a fair
> amount of other header files, and translation units as well.

I scratch my head sometimes as to why some config options rebuild so
much stuff. One down, ? to go. :)

> Changing the value of CONFIG_DEV_BLK_INITRD is a common thing with build
> systems that generate two kernels: one with the initramfs and one
> without. buildroot is one of these build systems, OpenWrt is also
> another one that does this.
>
> This patch series proposes adding an empty initrd.h to satisfy the need
> for drivers/of/fdt.c to unconditionally include that file, and moves the
> custom __early_init_dt_declare_initrd() definition away from
> asm/memory.h
>
> This cuts the number of objects rebuilds from 1920 down to 26, so a
> factor 73 approximately.
>
> Apologies for the long CC list, please let me know how you would go
> about merging that and if another approach would be preferable, e.g:
> introducing a CONFIG_ARCH_INITRD_BELOW_START_OK Kconfig option or
> something like that.

There may be a better way as of 4.20 because bootmem is now gone and
only memblock is used. This should unify what each arch needs to do
with initrd early. We need the physical address early for memblock
reserving. Then later on we need the virtual address to access the
initrd. Perhaps we should just change initrd_start and initrd_end to
physical addresses (or add 2 new variables would be less invasive and
allow for different translation than __va()). The sanity checks and
memblock reserve could also perhaps be moved to a common location.

Alternatively, given arm64 is the only oddball, I'd be fine with an
"if (IS_ENABLED(CONFIG_ARM64))" condition in the default
__early_init_dt_declare_initrd as long as we have a path to removing
it like the above option.

Rob
