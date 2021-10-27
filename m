From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Wed, 27 Oct 2021 23:09:07 +0000
Subject: Re: [PATCH v2 18/45] riscv: Use do_kernel_power_off()
Message-Id: <mhng-fd8f451c-4860-4b0c-a155-6f65891cd276@palmerdabbelt-glaptop>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20211027211715.12671-19-digetx@gmail.com>
References: <20211027211715.12671-19-digetx@gmail.com>
In-Reply-To: <20211027211715.12671-19-digetx@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: digetx@gmail.com
Cc: thierry.reding@gmail.com, jonathanh@nvidia.com, lee.jones@linaro.org, rafael@kernel.org, broonie@kernel.org, akpm@linux-foundation.org, linux@roeck-us.net, linux@armlinux.org.uk, daniel.lezcano@linaro.org, andriy.shevchenko@linux.intel.com, ulf.hansson@linaro.org, catalin.marinas@arm.com, will@kernel.org, guoren@kernel.org, geert@linux-m68k.org, gerg@linux-m68k.org, funaho@jurai.org, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, deanbo422@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Paul Walmsley <paul.walmsley@sifive.com>, aou@eecs.berkeley.edu, ysato@users.sourceforge.jp, dalias@libc.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, boris.ostrovsky@oracle.com, jgross@suse.com, sstabellini@kernel.org, lenb@kernel.org, ssantosh@kernel.org, krzysztof.kozlowski@canonical.com, linus.walleij@linaro.org, wens@csie.org, j.neuschaefer@gmx.net, tony@atomide.com, lgirdwood@gmail.com, p.zabel@pengutronix.de, vz@mleia.com, avifishman70@gmail.com, tmaimon77@gmail.com, tali.perry1@gmail.com, venture@google.com, yuenn@google.com, benjaminfair@google.com, pavel@ucw.cz, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, linux-omap@vger.kernel.org, openbmc@lists.ozlabs.org, linux-tegra@vger.kernel.org, linux-pm@vger.kernel.org

On Wed, 27 Oct 2021 14:16:48 PDT (-0700), digetx@gmail.com wrote:
> Kernel now supports chained power-off handlers. Use do_kernel_power_off()
> that invokes chained power-off handlers. It also invokes legacy
> pm_power_off() for now, which will be removed once all drivers will
> be converted to the new power-off API.
>
> Signed-off-by: Dmitry Osipenko <digetx@gmail.com>
> ---
>  arch/riscv/kernel/reset.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)
>
> diff --git a/arch/riscv/kernel/reset.c b/arch/riscv/kernel/reset.c
> index 9c842c41684a..912288572226 100644
> --- a/arch/riscv/kernel/reset.c
> +++ b/arch/riscv/kernel/reset.c
> @@ -23,16 +23,12 @@ void machine_restart(char *cmd)
>
>  void machine_halt(void)
>  {
> -	if (pm_power_off != NULL)
> -		pm_power_off();
> -	else
> -		default_power_off();
> +	do_kernel_power_off();
> +	default_power_off();
>  }
>
>  void machine_power_off(void)
>  {
> -	if (pm_power_off != NULL)
> -		pm_power_off();
> -	else
> -		default_power_off();
> +	do_kernel_power_off();
> +	default_power_off();
>  }

Acked-by: Palmer Dabbelt <palmer@dabbelt.com>
