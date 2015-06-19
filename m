From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Fri, 19 Jun 2015 23:42:24 +0000
Subject: Re: [PATCH 04/32] ACPI: sleep: Update acpi_set_firmware_waking_vector() invocations to favor 32-bit 
Message-Id: <3416587.jKQG8nL1MX@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1434684719.git.lv.zheng@intel.com> <2f708d4ee4100bd1b64ca1ea00b678d5f5b2135a.1434684719.git.lv.zheng@intel.com> <20150619062631.GA9668@gmail.com>
In-Reply-To: <20150619062631.GA9668@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Friday, June 19, 2015 08:26:31 AM Ingo Molnar wrote:
> 
> * Lv Zheng <lv.zheng@intel.com> wrote:
> 
> > This patch updates acpi_set_firmware_waking_vector() invocations in order
> > to keep 32-bit firmware waking vector favor for Linux.
> 
> This sentence does not parse.
> 
> > 64-bit firmware waking vector has never been enabled by Linux.  The
> > (acpi_physical_address)0 for 64-bit address can be used to force ACPICA to
> > set only 32-bit firmware waking vector for Linux.
> 
> So this is a change that affects a lot of systems - what is the expected 
> compatibility of this? Does Windows enable the 64-bit address? Which versions of 
> Windows?
> 
> > 
> > Reference: https://bugzilla.kernel.org/show_bug.cgi?idt021
> > Reported-and-tested-by: Oswald Buddenhagen <ossi@kde.org>
> > Signed-off-by: Lv Zheng <lv.zheng@intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: x86@kernel.org
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Fenghua Yu <fenghua.yu@intel.com>
> > Cc: linux-ia64@vger.kernel.org
> > ---
> >  arch/ia64/include/asm/acpi.h |    3 ++-
> >  arch/ia64/kernel/acpi.c      |    2 --
> >  arch/x86/include/asm/acpi.h  |    3 ++-
> >  drivers/acpi/sleep.c         |    8 ++++++--
> >  4 files changed, 10 insertions(+), 6 deletions(-)
> > 
> > diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
> > index aa0fdf1..0ac4fab 100644
> > --- a/arch/ia64/include/asm/acpi.h
> > +++ b/arch/ia64/include/asm/acpi.h
> > @@ -79,7 +79,8 @@ int acpi_gsi_to_irq (u32 gsi, unsigned int *irq);
> >  /* Low-level suspend routine. */
> >  extern int acpi_suspend_lowlevel(void);
> >  
> > -extern unsigned long acpi_wakeup_address;
> > +#define acpi_wakeup_address	((acpi_physical_address)0)
> > +#define acpi_wakeup_address64	((acpi_physical_address)0)
> >  
> >  /*
> >   * Record the cpei override flag and current logical cpu. This is
> > diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> > index b1698bc..1b08d6f 100644
> > --- a/arch/ia64/kernel/acpi.c
> > +++ b/arch/ia64/kernel/acpi.c
> > @@ -60,8 +60,6 @@ int acpi_lapic;
> >  unsigned int acpi_cpei_override;
> >  unsigned int acpi_cpei_phys_cpuid;
> >  
> > -unsigned long acpi_wakeup_address = 0;
> > -
> >  #ifdef CONFIG_IA64_GENERIC
> >  static unsigned long __init acpi_find_rsdp(void)
> >  {
> > diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
> > index 3a45668..fc9608d 100644
> > --- a/arch/x86/include/asm/acpi.h
> > +++ b/arch/x86/include/asm/acpi.h
> > @@ -72,7 +72,8 @@ static inline void acpi_disable_pci(void)
> >  extern int (*acpi_suspend_lowlevel)(void);
> >  
> >  /* Physical address to resume after wakeup */
> > -#define acpi_wakeup_address ((unsigned long)(real_mode_header->wakeup_start))
> > +#define acpi_wakeup_address	((acpi_physical_address)(real_mode_header->wakeup_start))
> > +#define acpi_wakeup_address64	((acpi_physical_address)(0))
> 
> Btw., 'acpi_physical_address' is a mouthful, and despite being a data type, it 
> looks like a variable name. Please rename it to something more sensible, matching 
> existing physical address patterns, like 'acpi_phys_addr_t'.

This is an ACPICA data type which means that it is used by multiple OSes, not only
by Linux.  We're just a user here. :-)


> Also, is there any reason why it's not simply phys_addr_t? It's not like ACPI has 
> a different notion of physical addresses.

Portability between different OSes is the reason.


> > diff --git a/drivers/acpi/sleep.c b/drivers/acpi/sleep.c
> > index 2f0d4db..3a6a2eb 100644
> > --- a/drivers/acpi/sleep.c
> > +++ b/drivers/acpi/sleep.c
> > @@ -25,6 +25,8 @@
> >  #include "internal.h"
> >  #include "sleep.h"
> >  
> > +#define ACPI_NO_WAKING_VECTOR		((acpi_physical_address)0)
> 
> So in x86 speak, 'vectors' are the things that drive interrupts. They are not 
> addresses. So calling it a 'vector' is a misnomer - it's a wakeup entry address 
> point.

But it is called "the waking vector" by the spec, so the naming here follows
the spec.


> Secondly, when the 64-bit entry point is configured, in what mode does the 
> firmware enter it - still real mode? Exactly what are the semantics when the 
> 64-bit entry point is set?

It can't do that in real mode, because the 64-bit one is only supposed to be
used when the entry point is above 4 GB in the physical address space.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
