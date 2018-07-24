From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 24 Jul 2018 09:54:25 +0000
Subject: Re: [PATCH] [SUBMITTED 20180724] arm64: fix ACPI dependencies
Message-Id: <CAJZ5v0jMtWDZePW=mu_cO2PjHVGp1hQThSveq9+=2aNozESENQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180724094957.1967541-1-arnd@arndb.de>
In-Reply-To: <20180724094957.1967541-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Will Deacon <will.deacon@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Tue, Jul 24, 2018 at 11:48 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> Kconfig reports a warning on x86 builds after the ARM64 dependency
> was added.
>
> drivers/acpi/Kconfig:6:error: recursive dependency detected!
> drivers/acpi/Kconfig:6:       symbol ACPI depends on EFI
>
> This rephrases the dependency to keep the ARM64 details out of the
> shared Kconfig file, so Kconfig no longer gets confused by it.
>
> For consistency, all three architectures that support ACPI now
> select ARCH_SUPPORTS_ACPI in exactly the configuration in which
> they allow it. We still need the 'default x86', as each one
> wants a different default: default-y on x86, default-n on arm64,
> and always-y on ia64.
>
> Fixes: 5bcd44083a08 ("drivers: acpi: add dependency of EFI for arm64")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: use 'select ARCH_SUPPORTS_ACPI' for all three.

LGTM

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
>  arch/arm64/Kconfig   | 1 +
>  arch/ia64/Kconfig    | 1 +
>  arch/x86/Kconfig     | 1 +
>  drivers/acpi/Kconfig | 8 +++++---
>  4 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index cdcaa6a798b2..2f987a938405 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1267,6 +1267,7 @@ config EFI
>         bool "UEFI runtime support"
>         depends on OF && !CPU_BIG_ENDIAN
>         depends on KERNEL_MODE_NEON
> +       select ARCH_SUPPORTS_ACPI
>         select LIBFDT
>         select UCS2_STRING
>         select EFI_PARAMS_FROM_FDT
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index ff861420b8f5..02eb68d5d1c0 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -16,6 +16,7 @@ config IA64
>         select ARCH_MIGHT_HAVE_PC_SERIO
>         select PCI if (!IA64_HP_SIM)
>         select ACPI if (!IA64_HP_SIM)
> +       select ARCH_SUPPORTS_ACPI if (!IA64_HP_SIM)
>         select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
>         select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
>         select HAVE_UNSTABLE_SCHED_CLOCK
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 088b719bc5d1..442575220708 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -76,6 +76,7 @@ config X86
>         select ARCH_MIGHT_HAVE_ACPI_PDC         if ACPI
>         select ARCH_MIGHT_HAVE_PC_PARPORT
>         select ARCH_MIGHT_HAVE_PC_SERIO
> +       select ARCH_SUPPORTS_ACPI
>         select ARCH_SUPPORTS_ATOMIC_RMW
>         select ARCH_SUPPORTS_NUMA_BALANCING     if X86_64
>         select ARCH_USE_BUILTIN_BSWAP
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index a8da730fabc6..1edca05ee0ae 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -5,11 +5,10 @@
>
>  menuconfig ACPI
>         bool "ACPI (Advanced Configuration and Power Interface) Support"
> -       depends on !IA64_HP_SIM
> -       depends on IA64 || X86 || (ARM64 && EFI)
> +       depends on ARCH_SUPPORTS_ACPI
>         depends on PCI
>         select PNP
> -       default y if (IA64 || X86)
> +       default y if X86
>         help
>           Advanced Configuration and Power Interface (ACPI) support for
>           Linux requires an ACPI-compliant platform (hardware/firmware),
> @@ -41,6 +40,9 @@ menuconfig ACPI
>           <http://www.acpi.info>
>           <http://www.uefi.org/acpi/specs>
>
> +config ARCH_SUPPORTS_ACPI
> +       bool
> +
>  if ACPI
>
>  config ACPI_LEGACY_TABLES_LOOKUP
> --
> 2.18.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
