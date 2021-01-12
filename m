From: Will Deacon <will@kernel.org>
Date: Tue, 12 Jan 2021 14:05:00 +0000
Subject: Re: [PATCH v2] arch: consolidate pm_power_off callback
Message-Id: <20210112140459.GC9277@willie-the-truck>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201227140129.19932-1-info@metux.net>
In-Reply-To: <20201227140129.19932-1-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, catalin.marinas@arm.com, msalter@redhat.com, jacquiot.aurelien@gmail.com, ysato@users.sourceforge.jp, geert@linux-m68k.org, tsbogend@alpha.franken.de, ley.foon.tan@intel.com, jonas@southpole.se, stefan.kristiansson@saunalahti.fi, shorne@gmail.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, dalias@libc.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, sstabellini@kernel.org, chris@zankel.net, jcmvbkbc@gmail.com, christian@brauner.io, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-pm@vger.kernel.org

On Sun, Dec 27, 2020 at 03:01:28PM +0100, Enrico Weigelt, metux IT consult wrote:
> Move the pm_power_off callback into one global place and also add an
> function for conditionally calling it (when not NULL), in order to remove
> code duplication in all individual archs.
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Signed-off-by: Enrico Weigelt, metux IT consult <info@metux.net>

[...]

> diff --git a/kernel/reboot.c b/kernel/reboot.c
> index eb1b15850761..ec4cd66dd1ae 100644
> --- a/kernel/reboot.c
> +++ b/kernel/reboot.c
> @@ -53,6 +53,16 @@ int reboot_force;
>  void (*pm_power_off_prepare)(void);
>  EXPORT_SYMBOL_GPL(pm_power_off_prepare);
>  
> +void (*pm_power_off)(void);
> +EXPORT_SYMBOL_GPL(pm_power_off);
> +
> +void do_power_off(void)
> +{
> +	if (pm_power_off)
> +		pm_power_off();
> +}
> +EXPORT_SYMBOL_GPL(do_power_off);

Could this just live as a static inline in pm.h to avoid having to export
the extra symbol?

Will
