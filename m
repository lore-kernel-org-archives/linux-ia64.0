From: Ashwin Chaugule <ashwin.chaugule@linaro.org>
Date: Thu, 24 Sep 2015 10:31:52 +0000
Subject: Re: [PATCH v2 4/5] ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <CAJ5Y-eb6SfQtR0aigPo4F-ueDk+J93NKf62KCM_NiK44nBQ3Sw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
	<1442411963-14398-1-git-send-email-sudeep.holla@arm.com>
	<1442411963-14398-5-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1442411963-14398-5-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux acpi <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>

Hi Sudeep,

On 16 September 2015 at 09:59, Sudeep Holla <sudeep.holla@arm.com> wrote:
> ACPI 6.0 adds a new method to specify the CPU idle states(C-states)
> called Low Power Idle(LPI) states. Since new architectures like ARM64
> use only LPIs, introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE to
> encapsulate all the code supporting the old style C-states(_CST)
>
> This patch will help to extend the processor_idle module to support
> LPI.
>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
> ---
>  arch/ia64/Kconfig             |  1 +
>  arch/x86/Kconfig              |  1 +
>  drivers/acpi/Kconfig          |  3 +++
>  drivers/acpi/processor_idle.c | 57 +++++++++++++++++++++++++++++++------------
>  include/acpi/processor.h      |  3 ++-
>  5 files changed, 49 insertions(+), 16 deletions(-)
>
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index eb0249e37981..dbfa3c3a49e1 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -16,6 +16,7 @@ config IA64
>         select PCI if (!IA64_HP_SIM)
>         select ACPI if (!IA64_HP_SIM)
>         select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
> +       select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
>         select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
>         select HAVE_UNSTABLE_SCHED_CLOCK
>         select HAVE_IDE
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 7aef2d52daa0..173075c48df8 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -34,6 +34,7 @@ config X86
>         select ARCH_MIGHT_HAVE_ACPI_PDC         if ACPI
>         select ARCH_MIGHT_HAVE_PC_PARPORT
>         select ARCH_MIGHT_HAVE_PC_SERIO
> +       select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
>         select ARCH_SUPPORTS_ATOMIC_RMW
>         select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>         select ARCH_SUPPORTS_INT128             if X86_64
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index 5d1015c26ff4..1eb0b8a84a65 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -48,6 +48,9 @@ config ACPI_LEGACY_TABLES_LOOKUP
>  config ARCH_MIGHT_HAVE_ACPI_PDC
>         bool
>
> +config ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
> +       bool
> +
>  config ACPI_GENERIC_GSI
>         bool
>

Can't this be auto selected under ACPI_PROCESSOR_IDLE if X86 || IA64 instead?

Regards,
Ashwin.
