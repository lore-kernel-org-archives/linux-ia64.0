From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 13 Oct 2021 08:38:01 +0000
Subject: Re: [PATCH AUTOSEL 5.10 11/11] firmware: include drivers/firmware/Kconfig unconditionally
Message-Id: <CAK8P3a2AC9-ogoxi1q+NQyBqMwrFqSZtHvZVdJ9HF+OLB3O62g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211013005532.700190-1-sashal@kernel.org> <20211013005532.700190-11-sashal@kernel.org>
 <YWZ1om+pLmV3atTd@kroah.com>
In-Reply-To: <YWZ1om+pLmV3atTd@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Sasha Levin <sashal@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "# 3.4.x" <stable@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Bjorn Andersson <bjorn.andersson@linaro.org>, Charles Keepax <ckeepax@opensource.cirrus.com>, Will Deacon <will@kernel.org>, Mark Brown <broonie@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Simon Trimmer <simont@opensource.cirrus.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, the arch/x86 maintainers <x86@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, Russell King <rmk+kernel@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ardb@kernel.org>, =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?= <u.kleine-koenig@pengutronix.de>, Mike Rapoport <rppt@kernel.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Sergei Trofimovich <slyfox@gentoo.org>, Jens Axboe <axboe@kernel.dk>, ben.widawsky@intel.com, Dan Williams <dan.j.williams@intel.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>

On Wed, Oct 13, 2021 at 7:58 AM Greg KH <gregkh@linuxfoundation.org> wrote:
> On Tue, Oct 12, 2021 at 08:55:31PM -0400, Sasha Levin wrote:
>
> This isn't for stable kernels, it should be dropped from all of your
> AUTOSEL queues.

Agreed. The second patch that depends on this does fix a (randconfig)
build issue in stable kernels as well, but that patch is currently broken,
and the two patches combined do feel a little too invasive for addressing
such a minor issue in the stable kernels.

If anyone runs into the QCOM_SCM link failures on stable kernels, I
can come up with a more localized fix.

       Arnd
