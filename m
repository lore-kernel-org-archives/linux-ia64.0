From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Tue, 08 Jul 2014 20:52:15 +0000
Subject: Re: [PATCH v7 00/10] xen: Add EFI support
Message-Id: <20140708205215.GC3474@olila.local.net-space.pl>
List-Id: <linux-ia64.vger.kernel.org>
References: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
 <20140707194914.GA27474@console-pimps.org>
In-Reply-To: <20140707194914.GA27474@console-pimps.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matt Fleming <matt@console-pimps.org>
Cc: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org, andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

On Mon, Jul 07, 2014 at 08:49:14PM +0100, Matt Fleming wrote:
> On Mon, 30 Jun, at 07:52:54PM, Daniel Kiper wrote:
> > Hey,
> >
> > This patch series adds EFI support for Xen dom0 guests.
> > It is based on Jan Beulich and Tang Liang work. I was
> > trying to take into account all previous comments,
> > however, if I missed something sorry for that.
> >
> > Daniel
> >
> >  arch/ia64/include/asm/io.h       |    1 +
> >  arch/x86/kernel/setup.c          |    4 +-
> >  arch/x86/platform/efi/efi.c      |  106 ++++++++++--------------
> >  arch/x86/xen/enlighten.c         |   15 ++++
> >  drivers/firmware/efi/efi.c       |   25 +++---
> >  drivers/xen/Kconfig              |    4 +
> >  drivers/xen/Makefile             |    3 +
> >  drivers/xen/efi.c                |  368 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/efi.h              |    4 +-
> >  include/xen/interface/platform.h |  123 ++++++++++++++++++++++++++++
> >  include/xen/xen-ops.h            |   11 +++
> >  11 files changed, 587 insertions(+), 77 deletions(-)
> >
> > Daniel Kiper (10):
> >       arch/ia64: Define early_memunmap()
> >       efi: Use early_mem*() instead of early_io*()
> >       arch/x86: Do not access EFI memory map if it is not available
> >       efi: Introduce EFI_PARAVIRT flag
> >       arch/x86: Remove redundant set_bit(EFI_SYSTEM_TABLES) call
> >       arch/x86: Remove redundant set_bit(EFI_MEMMAP) call
> >       xen: Define EFI related stuff
> >       xen: Put EFI machinery in place
> >       arch/x86: Replace plain strings with constants
> >       arch/x86: Remove efi_set_rtc_mmss()
>
> Thanks Daniel.
>
> I've included Stefano's Acks where they were given and queued this up
> for v3.17 in the EFI 'next' branch at,
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/mfleming/efi.git

Great! Thanks a lot.

Daniel
