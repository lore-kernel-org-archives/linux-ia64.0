From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Wed, 24 Jun 2015 22:58:05 +0000
Subject: Re: [PATCH v2 03/28] ACPICA: Hardware: Enable 64-bit firmware waking vector for selected FACS.
Message-Id: <3959851.uJ0udqUY0b@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1434684719.git.lv.zheng@intel.com> <7ca3239e4066d1a33c523b1ccb475bcbfa6448d3.1435114811.git.lv.zheng@intel.com> <2100131.SXLpyPbXcH@vostro.rjw.lan>
In-Reply-To: <2100131.SXLpyPbXcH@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lv Zheng <lv.zheng@intel.com>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Bob Moore <robert.moore@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Wednesday, June 24, 2015 04:05:42 PM Rafael J. Wysocki wrote:
> On Wednesday, June 24, 2015 11:02:10 AM Lv Zheng wrote:
> > ACPICA commit 7aa598d711644ab0de5f70ad88f1e2de253115e4
> > 
> > The following commit is reported to have broken s2ram on some platforms:
> >  Commit: 0249ed2444d65d65fc3f3f64f398f1ad0b7e54cd
> >  ACPICA: Add option to favor 32-bit FADT addresses.
> > The platform reports 2 FACS tables (which is not allowed by ACPI
> > specification) and the new 32-bit address favor rule forces OSPMs to use
> > the FACS table reported via FADT's X_FIRMWARE_CTRL field.
> > 
> > The root cause of the reported bug might be one of the followings:
> > 1. BIOS may favor the 64-bit firmware waking vector address when the
> >    version of the FACS is greater than 0 and Linux currently only supports
> >    resuming from the real mode, so the 64-bit firmware waking vector has
> >    never been set and might be invalid to BIOS while the commit enables
> >    higher version FACS.
> > 2. BIOS may favor the FACS reported via the "FIRMWARE_CTRL" field in the
> >    FADT while the commit doesn't set the firmware waking vector address of
> >    the FACS reported by "FIRMWARE_CTRL", it only sets the firware waking
> >    vector address of the FACS reported by "X_FIRMWARE_CTRL".
> > 
> > This patch excludes the cases that can trigger the bugs caused by the root
> > cause 1.
> > 
> > ACPI specification says:
> > A. 32-bit FACS address (FIRMWARE_CTRL field in FADT):
> >    Physical memory address of the FACS, where OSPM and firmware exchange
> >    control information.
> >    If the X_FIRMWARE_CTRL field contains a non zero value then this field
> >    must be zero.
> >    A zero value indicates that no FACS is specified by this field.
> > B. 64-bit FACS address (X_FIRMWARE_CTRL field in FADT):
> >    64bit physical memory address of the FACS.
> >    This field is used when the physical address of the FACS is above 4GB.
> >    If the FIRMWARE_CTRL field contains a non zero value then this field
> >    must be zero.
> >    A zero value indicates that no FACS is specified by this field.
> > Thus the 32bit and 64bit firmware waking vector should indicate completely
> > different resuming environment - real mode (1MB addressable) and non real
> > mode (4GB+ addressable) and currently Linux only supports resuming from
> > real mode.
> > 
> > This patch enables 64-bit firmware waking vector for selected FACS via
> > acpi_set_firmware_waking_vector() so that it's up to OSPMs to determine which
> > resuming mode should be used by BIOS and ACPICA changes won't trigger the
> > bugs caused by the root cause 1. For example, Linux can pass
> > physical_address64=0 as the parameter of acpi_set_firmware_waking_vector() to
> > indicate no 64bit waking vector support. Lv Zheng.
> > 
> > This patch also updates acpi_set_firmware_waking_vector() invocations in
> > order to keep 32-bit firmware waking vector favor for Linux. 64-bit
> > firmware waking vector has never been enabled by Linux.  The
> > (acpi_physical_address)0 for 64-bit address can be used to force ACPICA to
> > set only 32-bit firmware waking vector for Linux.
> > 
> > Link: https://bugzilla.kernel.org/show_bug.cgi?idt021
> > Link: https://github.com/acpica/acpica/commit/7aa598d7
> > Cc: 3.14.1+ <stable@vger.kernel.org> # 3.14.1+
> > Reported-and-tested-by: Oswald Buddenhagen <ossi@kde.org>
> > Signed-off-by: Lv Zheng <lv.zheng@intel.com>
> > Signed-off-by: Bob Moore <robert.moore@intel.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: x86@kernel.org
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Fenghua Yu <fenghua.yu@intel.com>
> > Cc: linux-ia64@vger.kernel.org
> > ---
> >  arch/ia64/include/asm/acpi.h    |    3 +-
> >  arch/ia64/kernel/acpi.c         |    2 --
> >  arch/x86/include/asm/acpi.h     |    3 +-
> >  drivers/acpi/acpica/hwxfsleep.c |   61 ++++++++++++---------------------------
> >  drivers/acpi/sleep.c            |    8 +++--
> >  include/acpi/acpixf.h           |   11 +++----
> >  6 files changed, 33 insertions(+), 55 deletions(-)
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
> Do we need this?

In fact, I don't see why we need to redefine the symbols at all.

Couldn't acpi_set_firmware_waking_vector() be defined to take u32 and u64 so
we could just pass acpi_wakeup_address (as already defined) as the first argument
and 0 as the second argument to it?  The back-and-forth type casts from and
to acpi_physical_address don't look entirely clean to me.

Moreover, I don't really see a functional difference between the old and the
new code.

The old code does "set the 32-bit waking vector and clear the 64-bit waking
vector if present".  The new code does "set the 32-bit waking vector and
either clear the 64-bit one if present, or assign the second function argument
to it", but we always pass 0 as the second argument (which is *extremely*
obfuscated in your patch), so I really don't see the difference here.

Am I missing anything?

Rafael

