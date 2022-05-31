From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 31 May 2022 19:04:12 +0000
Subject: Re: [PATCH v8 16/27] m68k: Switch to new sys-off handler API
Message-Id: <CAMuHMdUFqf58F31EAGnhp_cu9k-G4Sx1cmwx-PGb3mU+6bjRnQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509233235.995021-1-dmitry.osipenko@collabora.com> <20220509233235.995021-17-dmitry.osipenko@collabora.com>
In-Reply-To: <20220509233235.995021-17-dmitry.osipenko@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dmitry Osipenko <dmitry.osipenko@collabora.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Sebastian Reichel <sre@kernel.org>, Linus Walleij <linus.walleij@linaro.org>, Philipp Zabel <p.zabel@pengutronix.de>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, Liam Girdwood <lgirdwood@gmail.com>, Mark Brown <broonie@kernel.org>, Pavel Machek <pavel@ucw.cz>, Lee Jones <lee.jones@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Linux-sh list <linux-sh@vger.kernel.org>, xen-devel@lists.xenproject.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-tegra <linux-tegra@vger.kernel.org>

Hi Dmitry,

On Tue, May 10, 2022 at 1:34 AM Dmitry Osipenko
<dmitry.osipenko@collabora.com> wrote:
> Kernel now supports chained power-off handlers. Use
> register_power_off_handler() that registers power-off handlers and
> do_kernel_power_off() that invokes chained power-off handlers. Legacy
> pm_power_off() will be removed once all drivers will be converted to
> the new sys-off API.
>
> Normally arch code should adopt only the do_kernel_power_off() at first,
> but m68k is a special case because it uses pm_power_off() "inside out",
> i.e. pm_power_off() invokes machine_power_off() [in fact it does nothing],
> while it's machine_power_off() that should invoke the pm_power_off(), and
> thus, we can't convert platforms to the new API separately. There are only
> two platforms changed here, so it's not a big deal.
>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Reviewed-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
> Signed-off-by: Dmitry Osipenko <dmitry.osipenko@collabora.com>

Thanks for your patch, which is now commit f0f7e5265b3b37b0
("m68k: Switch to new sys-off handler API") upstream.

> --- a/arch/m68k/emu/natfeat.c
> +++ b/arch/m68k/emu/natfeat.c
> @@ -15,6 +15,7 @@
>  #include <linux/string.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> +#include <linux/reboot.h>
>  #include <linux/io.h>
>  #include <asm/machdep.h>
>  #include <asm/natfeat.h>
> @@ -90,5 +91,5 @@ void __init nf_init(void)
>         pr_info("NatFeats found (%s, %lu.%lu)\n", buf, version >> 16,
>                 version & 0xffff);
>
> -       mach_power_off = nf_poweroff;
> +       register_platform_power_off(nf_poweroff);

Unfortunately nothing is registered, as this is called very early
(from setup_arch(), before the memory allocator is available.
Hence register_sys_off_handler() fails with -ENOMEM, and poweroff
stops working.

Possible solutions:
  - As at most one handler can be registered,
    register_platform_power_off() could use a static struct sys_off_handler
    instance,
  - Keep mach_power_off, and call register_platform_power_off() later.

Anything else?
Thanks!

> --- a/arch/m68k/mac/config.c
> +++ b/arch/m68k/mac/config.c
> @@ -12,6 +12,7 @@
>
>  #include <linux/errno.h>
>  #include <linux/module.h>
> +#include <linux/reboot.h>
>  #include <linux/types.h>
>  #include <linux/mm.h>
>  #include <linux/tty.h>
> @@ -140,7 +141,6 @@ void __init config_mac(void)
>         mach_hwclk = mac_hwclk;
>         mach_reset = mac_reset;
>         mach_halt = mac_poweroff;
> -       mach_power_off = mac_poweroff;
>  #if IS_ENABLED(CONFIG_INPUT_M68K_BEEP)
>         mach_beep = mac_mksound;
>  #endif
> @@ -160,6 +160,8 @@ void __init config_mac(void)
>
>         if (macintosh_config->ident = MAC_MODEL_IICI)
>                 mach_l2_flush = via_l2_flush;
> +
> +       register_platform_power_off(mac_poweroff);
>  }

This must have the same problem.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
