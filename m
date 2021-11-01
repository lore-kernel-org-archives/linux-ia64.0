From: Guo Ren <guoren@kernel.org>
Date: Mon, 01 Nov 2021 01:57:10 +0000
Subject: Re: [PATCH v2 12/45] csky: Use do_kernel_power_off()
Message-Id: <CAJF2gTT+EsLt+pnYyTw_B0C8isho=E4tfOWROe9h-GZpYjET=w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211027211715.12671-1-digetx@gmail.com> <20211027211715.12671-13-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-13-digetx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Osipenko <digetx@gmail.com>
Cc: Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Lee Jones <lee.jones@linaro.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Mark Brown <broonie@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Guenter Roeck <linux@roeck-us.net>, Russell King <linux@armlinux.org.uk>, Daniel Lezcano <daniel.lezcano@linaro.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Ulf Hansson <ulf.hansson@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Joshua Thompson <funaho@jurai.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Len Brown <lenb@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Krzysztof Kozlowski <krzysztof.kozlowski@canonical.com>, Linus Walleij <linus.walleij@linaro.org>, Chen-Yu Tsai <wens@csie.org>, =?UTF-8?Q?Jonathan_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Tony Lindgren <tony@atomide.com>, Liam Girdwood <lgirdwood@gmail.com>, Philipp Zabel <p.zabel@pengutronix.de>, Vladimir Zapolskiy <vz@mleia.com>, Avi Fishman <avifishman70@gmail.com>, Tomer Maimon <tmaimon77@gmail.com>, Tali Perry <tali.perry1@gmail.com>, Patrick Venture <venture@google.com>, Nancy Yuen <yuenn@google.com>, Benjamin Fair <benjaminfair@google.com>, Pavel Machek <pavel@ucw.cz>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv <linux-riscv@lists.infradead.org>, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org

Only for this patch, Acked-by: Guo Ren <guoren@kernel.org>

On Thu, Oct 28, 2021 at 5:18 AM Dmitry Osipenko <digetx@gmail.com> wrote:
>
> Kernel now supports chained power-off handlers. Use do_kernel_power_off()
> that invokes chained power-off handlers. It also invokes legacy
> pm_power_off() for now, which will be removed once all drivers will
> be converted to the new power-off API.
>
> Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
> ---
>  arch/csky/kernel/power.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/arch/csky/kernel/power.c b/arch/csky/kernel/power.c
> index 923ee4e381b8..86ee202906f8 100644
> --- a/arch/csky/kernel/power.c
> +++ b/arch/csky/kernel/power.c
> @@ -9,16 +9,14 @@ EXPORT_SYMBOL(pm_power_off);
>  void machine_power_off(void)
>  {
>         local_irq_disable();
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         asm volatile ("bkpt");
>  }
>
>  void machine_halt(void)
>  {
>         local_irq_disable();
> -       if (pm_power_off)
> -               pm_power_off();
> +       do_kernel_power_off();
>         asm volatile ("bkpt");
>  }
>
> --
> 2.33.1
>


-- 
Best Regards
 Guo Ren

ML: https://lore.kernel.org/linux-csky/
