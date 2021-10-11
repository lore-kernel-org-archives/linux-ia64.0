From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 11 Oct 2021 08:42:00 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <CAMuHMdXspk27xd95YAsXa73ES8rfKxii3RUEtsBtxQTk9qLztA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org> <9dedf9bb-5377-9f2c-cbb1-2a57b40493da@molgen.mpg.de>
In-Reply-To: <9dedf9bb-5377-9f2c-cbb1-2a57b40493da@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: Arnd Bergmann <arnd@kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Charles Keepax <ckeepax@opensource.cirrus.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Oct 9, 2021 at 11:24 AM Paul Menzel <pmenzel@molgen.mpg.de> wrote:
> [Cc: +linuxppc-dev@lists.ozlabs.org]
>
> Am 28.09.21 um 09:50 schrieb Arnd Bergmann:
> > From: Arnd Bergmann <arnd@arndb.de>
> >
> > Compile-testing drivers that require access to a firmware layer
> > fails when that firmware symbol is unavailable. This happened
> > twice this week:
> >
> >   - My proposed to change to rework the QCOM_SCM firmware symbol
> >     broke on ppc64 and others.
> >
> >   - The cs_dsp firmware patch added device specific firmware loader
> >     into drivers/firmware, which broke on the same set of
> >     architectures.
> >
> > We should probably do the same thing for other subsystems as well,
> > but fix this one first as this is a dependency for other patches
> > getting merged.
> >

> With this change, I have the new entries below in my .config:
>
> ```
> $ diff -u .config.old .config
> --- .config.old 2021-10-07 11:38:39.544000000 +0200
> +++ .config     2021-10-09 10:02:03.156000000 +0200
> @@ -1992,6 +1992,25 @@
>
>   CONFIG_CONNECTOR=y
>   CONFIG_PROC_EVENTS=y
> +
> +#
> +# Firmware Drivers
> +#
> +
> +#
> +# ARM System Control and Management Interface Protocol
> +#
> +# end of ARM System Control and Management Interface Protocol
> +
> +# CONFIG_FIRMWARE_MEMMAP is not set
> +# CONFIG_GOOGLE_FIRMWARE is not set
> +
> +#
> +# Tegra firmware driver
> +#
> +# end of Tegra firmware driver
> +# end of Firmware Drivers
> +
>   # CONFIG_GNSS is not set
>   CONFIG_MTD=m
>   # CONFIG_MTD_TESTS is not set
> ```
>
> No idea if the entries could be hidden for platforms not supporting them.
>
>          ARM System Control and Management Interface Protocol  ----
>      [ ] Add firmware-provided memory map to sysfs
>      [ ] Google Firmware Drivers  ----
>          Tegra firmware driver  ----

GOOGLE_FIRMWARE should probably depend on something.
I highly doubt Google is running servers on e.g. h8300 and nds32.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
