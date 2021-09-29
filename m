From: Will Deacon <will@kernel.org>
Date: Wed, 29 Sep 2021 10:17:21 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <20210929101721.GC21057@willie-the-truck>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org>
In-Reply-To: <20210928075216.4193128-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Charles Keepax <ckeepax@opensource.cirrus.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org

On Tue, Sep 28, 2021 at 09:50:26AM +0200, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
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
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Liam Girdwood <lgirdwood@gmail.com>
> Cc: Charles Keepax <ckeepax@opensource.cirrus.com>
> Cc: Simon Trimmer <simont@opensource.cirrus.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
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
> ---
>  arch/arm/Kconfig    | 2 --
>  arch/arm64/Kconfig  | 2 --
>  arch/ia64/Kconfig   | 2 --
>  arch/mips/Kconfig   | 2 --
>  arch/parisc/Kconfig | 2 --
>  arch/riscv/Kconfig  | 2 --
>  arch/x86/Kconfig    | 2 --
>  drivers/Kconfig     | 2 ++
>  8 files changed, 2 insertions(+), 14 deletions(-)

For arm64:

Acked-by: Will Deacon <will@kernel.org>

Will
