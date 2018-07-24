From: Will Deacon <will.deacon@arm.com>
Date: Tue, 24 Jul 2018 10:21:03 +0000
Subject: Re: [PATCH] [SUBMITTED 20180724] arm64: fix ACPI dependencies
Message-Id: <20180724102102.GI19324@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180724094957.1967541-1-arnd@arndb.de>
 <CAJZ5v0jMtWDZePW=mu_cO2PjHVGp1hQThSveq9+=2aNozESENQ@mail.gmail.com>
In-Reply-To: <CAJZ5v0jMtWDZePW=mu_cO2PjHVGp1hQThSveq9+=2aNozESENQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Tue, Jul 24, 2018 at 11:54:25AM +0200, Rafael J. Wysocki wrote:
> On Tue, Jul 24, 2018 at 11:48 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > Kconfig reports a warning on x86 builds after the ARM64 dependency
> > was added.
> >
> > drivers/acpi/Kconfig:6:error: recursive dependency detected!
> > drivers/acpi/Kconfig:6:       symbol ACPI depends on EFI
> >
> > This rephrases the dependency to keep the ARM64 details out of the
> > shared Kconfig file, so Kconfig no longer gets confused by it.
> >
> > For consistency, all three architectures that support ACPI now
> > select ARCH_SUPPORTS_ACPI in exactly the configuration in which
> > they allow it. We still need the 'default x86', as each one
> > wants a different default: default-y on x86, default-n on arm64,
> > and always-y on ia64.
> >
> > Fixes: 5bcd44083a08 ("drivers: acpi: add dependency of EFI for arm64")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> > v2: use 'select ARCH_SUPPORTS_ACPI' for all three.
> 
> LGTM
> 
> Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Same here:

Acked-by: Will Deacon <will.deacon@arm.com>

Would it be ok if I take this via the arm64 tree, since that's where the
warning was introduced?

Will
