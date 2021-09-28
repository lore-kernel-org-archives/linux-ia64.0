From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 28 Sep 2021 08:51:36 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <CAK8P3a11c6eLRWKvQeSqvEicc9bMDeEEGV5fygTidoRzYf9KnQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org> <20210928083751.GG9223@ediswmail.ad.cirrus.com>
In-Reply-To: <20210928083751.GG9223@ediswmail.ad.cirrus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Charles Keepax <ckeepax@opensource.cirrus.com>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Tue, Sep 28, 2021 at 10:37 AM Charles Keepax
<ckeepax@opensource.cirrus.com> wrote:
>
> Thanks for looking at this for us. I don't think we are greatly
> attached to drivers/firmware as a location. Essentially, what we
> have is some firmware parsing code that needs to be shared across
> several devices, previously this was just in the sound subsystem as
> all our parts were audio. We are going to shortly be upstreaming
> some non-audio parts that use the same firmware infrastructure
> and it didn't seem very sensible to have them including bits of
> the audio subsystem.
>
> I guess the question might be where else would said code go?
> drivers/firmware seemed most obvious, all the other locations
> I can think of don't really make sense. Can't really put it a bus
> like spi/i2c etc. because we have parts on many buses. Can't
> really put it in a functional subsystem (audio/input etc.) since
> the whole idea was to try and get some independence from that so
> we don't have parts including subsystems they don't use. Could
> maybe put it in MFD, but no hard guarantee every part using it
> will be an MFD device and I am fairly confident Lee will feel it
> isn't MFD code as it doesn't relate to managing multiple devices.
> Only other option I can think of would be to make some sort of
> drivers/dsp or maybe drivers/cs_dsp, but not clear to me that is
> obviously better than using drivers/firmware.

Other DSPs use the drivers/remoteproc/ subsystem, but that
is more for general-purpose DSPs that can load application
specific firmware rather than loading a single firmware blob
as you'd normally do with the request_firmware() style interface.

Not sure if that fits what you do. Can you point to a high-level
description of what this DSP does besides audio, and how
flexible it is? That might help find the right place for this.

       Arnd
