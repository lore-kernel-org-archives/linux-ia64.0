From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 07 Aug 2015 16:57:01 +0000
Subject: Re: [PATCH 2/5] ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
Message-Id: <20150807165701.GI19308@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438894770-31163-1-git-send-email-al.stone@linaro.org>
 <1438894770-31163-3-git-send-email-al.stone@linaro.org>
In-Reply-To: <1438894770-31163-3-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>, patches@linaro.org, Marc Zyngier <marc.zyngier@arm.com>, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, Aug 06, 2015 at 02:59:27PM -0600, Al Stone wrote:
> Now that we have introduced the bad_madt_entry() function, and that
> function is being invoked in acpi_table_parse_madt() for us, there
> is no longer any need to use the BAD_MADT_ENTRY macro, or in the case
> of arm64, the BAD_MADT_GICC_ENTRY, too.
> 
> Signed-off-by: Al Stone <al.stone@linaro.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: Marc Zyngier <marc.zyngier@arm.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
