From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 11 Oct 2021 09:45:47 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <CAK8P3a3s5tu8MfdtXpoCeA8rrAUD3sscCMqLaoUVdUY9G-9AvQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org> <9dedf9bb-5377-9f2c-cbb1-2a57b40493da@molgen.mpg.de>
 <CAMuHMdXspk27xd95YAsXa73ES8rfKxii3RUEtsBtxQTk9qLztA@mail.gmail.com>
In-Reply-To: <CAMuHMdXspk27xd95YAsXa73ES8rfKxii3RUEtsBtxQTk9qLztA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Paul Menzel <pmenzel@molgen.mpg.de>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Charles Keepax <ckeepax@opensource.cirrus.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon, Oct 11, 2021 at 10:42 AM Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> On Sat, Oct 9, 2021 at 11:24 AM Paul Menzel <pmenzel@molgen.mpg.de> wrote:
> > Am 28.09.21 um 09:50 schrieb Arnd Bergmann:
> > > From: Arnd Bergmann <arnd@arndb.de>
> > +#
> > +# ARM System Control and Management Interface Protocol
> > +#
> > +# end of ARM System Control and Management Interface Protocol
> > +
> > +# CONFIG_FIRMWARE_MEMMAP is not set
> > +# CONFIG_GOOGLE_FIRMWARE is not set
> > +
> > +#
> > +# Tegra firmware driver
> > +#
> > +# end of Tegra firmware driver
> > +# end of Firmware Drivers
> > +
> >   # CONFIG_GNSS is not set
> >   CONFIG_MTD=m
> >   # CONFIG_MTD_TESTS is not set
> > ```
> >
> > No idea if the entries could be hidden for platforms not supporting them.
> >
> >          ARM System Control and Management Interface Protocol  ----
> >      [ ] Add firmware-provided memory map to sysfs
> >      [ ] Google Firmware Drivers  ----
> >          Tegra firmware driver  ----
>
> GOOGLE_FIRMWARE should probably depend on something.
> I highly doubt Google is running servers on e.g. h8300 and nds32.

GOOGLE_FIRMWARE is only the 'menuconfig' option that contains
the other options, but on architectures that have neither CONFIG_OF
nor CONFIG_ACPI, this is empty.  Most architectures of course
do support or require CONFIG_OF, so it's unclear whether we should
show the options for coreboot. Since it's a software-only driver, I
would tend to keep showing it, given that coreboot can be ported
to every architecture. The DT binding [1] seems to be neither
Google nor Arm specific.

CONFIG_FIRMWARE_MEMMAP in turn can be used for
anything that has memory hotplug, and in theory additional
drivers that register with this interface.

I'd lean towards "leave as is" for both, to avoid having to
change the dependencies again whenever something else
can use these.

        Arnd

[1] Documentation/devicetree/bindings/firmware/coreboot.txt
