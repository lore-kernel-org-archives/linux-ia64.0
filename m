From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 24 May 2022 15:03:19 +0000
Subject: Re: [PATCH v8 07/27] kernel/reboot: Add kernel_can_power_off()
Message-Id: <CAMuHMdWBWWVeegvLQQzT8CRL5z38AhXigaNjzw8p0NwQ1B4DPQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com>
 <20220509233235.995021-8-dmitry.osipenko@collabora.com> <CAMuHMdVGjeFe=Z_1Kr9ZaNZ7HUVH1usvubEB31WUQf0fg8E1kA@mail.gmail.com>
 <c4914e14-1882-55a1-bcbd-a905852b45a3@collabora.com>
In-Reply-To: <c4914e14-1882-55a1-bcbd-a905852b45a3@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>

Hi Dmitry,

On Tue, May 24, 2022 at 3:41 PM Dmitry Osipenko
<dmitry.osipenko@collabora.com> wrote:
> On 5/24/22 16:14, Geert Uytterhoeven wrote:
> > On Tue, May 10, 2022 at 1:33 AM Dmitry Osipenko
> > <dmitry.osipenko@collabora.com> wrote:
> >> Add kernel_can_power_off() helper that replaces open-coded checks of
> >> the global pm_power_off variable. This is a necessary step towards
> >> supporting chained power-off handlers.
> >>
> >> Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>
> >
> > Thanks for your patch, which is now commit 0e2110d2e910e44c
> > ("kernel/reboot: Add kernel_can_power_off()") in pm/linux-next.
> >
> > This causes the "poweroff" command (Debian nfsroot) to no longer
> > cleanly halt the system on arm32 systems, but fail with a panic
> > instead:
> >
> > -reboot: System halted
> > +reboot: Power down
> > +Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000000
> > +CPU: 0 PID: 1 Comm: systemd-shutdow Not tainted
> > 5.18.0-rc7-shmobile-00007-g0e2110d2e910 #1274
> > +Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
> > + unwind_backtrace from show_stack+0x10/0x14
> > + show_stack from dump_stack_lvl+0x40/0x4c
> > + dump_stack_lvl from panic+0xf4/0x330
> > + panic from do_exit+0x1c8/0x8e4
> > + do_exit from __do_sys_reboot+0x174/0x1fc
> > + __do_sys_reboot from ret_fast_syscall+0x0/0x54
> > +Exception stack(0xf0815fa8 to 0xf0815ff0)
> > +5fa0:                   004e6954 00000000 fee1dead 28121969 4321fedc f0d94600
> > +5fc0: 004e6954 00000000 00000000 00000058 befa0c78 00000000 befa0c10 004e56f8
> > +5fe0: 00000058 befa0b6c b6ec8d45 b6e4a746
> > +---[ end Kernel panic - not syncing: Attempted to kill init!
> > exitcode=0x00000000 ]---
> >
> > On arm64, "poweroff" causes a clean "reboot: Power down" before/after.
> >
> > On both arm32 and arm64, the same handlers are registered:
> >   - SYS_OFF_MODE_POWER_OFF_PREPARE: legacy_pm_power_off_prepare
> >   - SYS_OFF_MODE_POWER_OFF: legacy_pm_power_off
> >
> > On both arm32 and arm64, legacy_pm_power_off_prepare() is called.
> > On both arm32 and arm64, legacy_pm_power_off() does not seem to
> > be called.
> >
> > On arm32, both pm_power_off_prepare and pm_power_off are NULL.
> > On arm64, pm_power_off_prepare is NULL, and
> > pm_power_off is psci_sys_poweroff.
> >
> > Do you have a clue?
> > Thanks!
>
> Thank you, Geert! I see the problem, the kernel_can_power_off() checks whether power-off handler is registered, but it's always registered because legacy_pm_power_off is registered unconditionally. So it causes trouble for platforms that don't have power-off handler installed at all. All platforms that I tested have a power-off handler, so now wonder that I didn't notice this before.
>
> This change should fix the problem, please give it a try:

Thank you, that fixes the problem for me!

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
