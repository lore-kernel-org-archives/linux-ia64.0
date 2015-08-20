From: Will Deacon <will.deacon@arm.com>
Date: Thu, 20 Aug 2015 10:13:22 +0000
Subject: Re: [PATCH v2 2/5] ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
Message-Id: <20150820101322.GA19328@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
 <1440022048-6285-3-git-send-email-al.stone@linaro.org>
In-Reply-To: <1440022048-6285-3-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <al.stone@linaro.org>
Cc: "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "patches@linaro.org" <patches@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>

Hi Al,

On Wed, Aug 19, 2015 at 11:07:25PM +0100, Al Stone wrote:
> Now that we have introduced the bad_madt_entry() function, and that
> function is being invoked in acpi_table_parse_madt() for us, there
> is no longer any need to use the BAD_MADT_ENTRY macro, or in the case
> of arm64, the BAD_MADT_GICC_ENTRY, too.
> 
> Signed-off-by: Al Stone <al.stone@linaro.org>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Marc Zyngier <marc.zyngier@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Jason Cooper <jason@lakedaemon.net>
> ---
>  arch/arm64/include/asm/acpi.h | 8 --------
>  arch/arm64/kernel/smp.c       | 2 --
>  drivers/irqchip/irq-gic.c     | 6 ------
>  3 files changed, 16 deletions(-)

How are you planning to merge this (and which kernel are you targetting?)
You've got Acks for both arm64 and irqchip, so I guess either of those
trees could take it.

Will
