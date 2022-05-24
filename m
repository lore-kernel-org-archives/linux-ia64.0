From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 24 May 2022 13:43:14 +0000
Subject: Re: [PATCH v8 00/27] Introduce power-off+restart call chain API
Message-Id: <CAJZ5v0jar8GONkAZfLuRpKHuYRu1Y_0AecmGxayM00AHCJkYVg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
 <CAJZ5v0jhWs-8ChHddebTZcaH6kA05sLEMsXM9Op7kHWAQDxeYA@mail.gmail.com> <CAMuHMdVbWpgubaA0V_tau3O=czAb3RQV9AwJsoQ+LWjf-wjMkA@mail.gmail.com>
In-Reply-To: <CAMuHMdVbWpgubaA0V_tau3O=czAb3RQV9AwJsoQ+LWjf-wjMkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Dmitry Osipenko <dmitry.osipenko@collabora.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

Hi Geert,

On Mon, May 23, 2022 at 8:08 PM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
> Hi Rafael,
>
> On Wed, May 18, 2022 at 4:46 PM Rafael J. Wysocki <rafael@kernel.org> wrote:
> > On Tue, May 10, 2022 at 1:33 AM Dmitry Osipenko
> > <dmitry.osipenko@collabora.com> wrote:
>
> > >   m68k: Switch to new sys-off handler API
>
> Sorry, I didn't realize this was going to interact with the new m68k
> virtual machine support, which is included in the m68k pull request
> for v5.19.
>
> > However, I'm going to send a pull request with it in the second half
> > of the merge window, after the majority of the other changes in the
> > subsystems touched by it have been integrated.
>
> And presumably you will have to merge in v5.19-rc1, too?

I will merge this series on top of the Linus' merges of my pull
requests sent yesterday (assuming that he pulls them, that is).

> I've sent a fix.  It should appear at
> https://lore.kernel.org/r/20220523175520.949681-1-geert@linux-m68k.org
> soon.
>
> Can you please include that in your PR?

I will.

Thanks!
