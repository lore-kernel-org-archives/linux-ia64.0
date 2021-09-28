From: Arnd Bergmann <arnd@kernel.org>
Date: Tue, 28 Sep 2021 12:22:59 +0000
Subject: Re: [PATCH 1/2] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <CAK8P3a05oRxgncJb04+niAKSO_2Adki03a04tnj8YuQT=Py54A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210928075216.4193128-1-arnd@kernel.org> <20210928115856.GK4199@sirena.org.uk>
In-Reply-To: <20210928115856.GK4199@sirena.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Brown <broonie@kernel.org>
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Liam Girdwood <lgirdwood@gmail.com>, Charles Keepax <ckeepax@opensource.cirrus.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Linus Walleij <linus.walleij@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Tue, Sep 28, 2021 at 1:58 PM Mark Brown <broonie@kernel.org> wrote:
> On Tue, Sep 28, 2021 at 09:50:26AM +0200, Arnd Bergmann wrote:
>
> > Not sure how we'd want to merge this patch, if two other things
> > need it. I'd prefer to merge it along with the QCOM_SCM change
> > through the soc tree, but that leaves the cirrus firmware broken
> > unless we also merge it the same way (rather than through ASoC
> > as it is now).
>
> We could also merge a tag into both places.

I wonder if I should just take my two patches as bugfixes for 5.15,
after all they do address real build failures. In that case, all  you need
is a merge with 5.15-rc4 or higher.

      Arnd
