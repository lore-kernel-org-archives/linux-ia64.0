From: Dmitry Osipenko <digetx@gmail.com>
Date: Thu, 27 Jan 2022 14:39:15 +0000
Subject: Re: [PATCH v5 04/21] kernel: Add combined power-off+restart handler call chain API
Message-Id: <e8d3ca39-ddeb-2c21-6000-1cc65da57915@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211212210309.9851-1-digetx@gmail.com>
 <20211212210309.9851-5-digetx@gmail.com> <Ydofs2CIfA+r5KAz@qmqm.qmqm.pl>
In-Reply-To: <Ydofs2CIfA+r5KAz@qmqm.qmqm.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, alankao@andestech.com, "K . C . Kuen-Chern Lin" <kclin@andestech.com>, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org, linux-tegra@vger.kernel.org

Hello Michał,

09.01.2022 02:35, Michał Mirosław пишет:
> BTW, I couldn't find a right description of my idea of unifying the
> chains before, so let me sketch it now.
> 
> The idea is to have a single system-off chain in which the callback
> gets a mode ({QUERY_*, PREP_*, DO_*} for each of {*_REBOOT, *_POWEROFF, ...?).
> The QUERY_* calls would be made in can_kernel_reboot/poweroff(): all
> would be called, and if at least one returned true, then the shutdown
> mode would continue. All of PREP_* would be called then. After that
> all DO_* would be tried until one doesn't return (succeeded or broke
> the system hard). Classic for(;;); could be a final fallback for the
> case where arch/machine (lowest priority) call would return instead
> of halting the system in machine-dependent way. The QUERY and PREP
> stages could be combined, but I haven't thought about it enough to
> see what conditions would need to be imposed on the callbacks in
> that case (maybe it's not worth the trouble, since it isn't a fast
> path anyway?). The goal here is to have less (duplicated) code in
> kernel, but otherwise it seems equivalent to your API proposal.

Thank you again for yours proposal! IMO, it's much more important to
keep the core code simple and maintainable, rather than try to optimize
it without a very good reason, given that this isn't a hot code path at
all and saving a couple of bytes won't be noticeable. The poweroff,
restart and reboot were separated before this series and I'm finding
that it's easier to follow the code when it's structured that way. I'm
not convinced that we need to change it.
