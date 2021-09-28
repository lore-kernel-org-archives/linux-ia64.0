From: Charles Keepax <ckeepax@opensource.cirrus.com>
Date: Tue, 28 Sep 2021 08:37:51 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20210928083751.GG9223@ediswmail.ad.cirrus.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org>
In-Reply-To: <20210928075216.4193128-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org

On Tue, Sep 28, 2021 at 09:50:26AM +0200, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Compile-testing drivers that require access to a firmware layer
> fails when that firmware symbol is unavailable. This happened
> twice this week:
> 
>  - My proposed to change to rework the QCOM_SCM firmware symbol
>    broke on ppc64 and others.
> 
>  - The cs_dsp firmware patch added device specific firmware loader
>    into drivers/firmware, which broke on the same set of
>    architectures.
> 
> We should probably do the same thing for other subsystems as well,
> but fix this one first as this is a dependency for other patches
> getting merged.
> 
> Not sure how we'd want to merge this patch, if two other things
> need it. I'd prefer to merge it along with the QCOM_SCM change
> through the soc tree, but that leaves the cirrus firmware broken
> unless we also merge it the same way (rather than through ASoC
> as it is now).
> 
> Alternatively, we can try to find a different home for the Cirrus
> firmware to decouple the two problems. I'd argue that it's actually
> misplaced here, as drivers/firmware is meant for kernel code that
> interfaces with system firmware, not for device drivers to load
> their own firmware blobs from user space.

Thanks for looking at this for us. I don't think we are greatly
attached to drivers/firmware as a location. Essentially, what we
have is some firmware parsing code that needs to be shared across
several devices, previously this was just in the sound subsystem as
all our parts were audio. We are going to shortly be upstreaming
some non-audio parts that use the same firmware infrastructure
and it didn't seem very sensible to have them including bits of
the audio subsystem.

I guess the question might be where else would said code go?
drivers/firmware seemed most obvious, all the other locations
I can think of don't really make sense. Can't really put it a bus
like spi/i2c etc. because we have parts on many buses. Can't
really put it in a functional subsystem (audio/input etc.) since
the whole idea was to try and get some independence from that so
we don't have parts including subsystems they don't use. Could
maybe put it in MFD, but no hard guarantee every part using it
will be an MFD device and I am fairly confident Lee will feel it
isn't MFD code as it doesn't relate to managing multiple devices.
Only other option I can think of would be to make some sort of
drivers/dsp or maybe drivers/cs_dsp, but not clear to me that is
obviously better than using drivers/firmware.

Thanks,
Charles
