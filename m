From: Samuel Ortiz <sameo@linux.intel.com>
Date: Sat, 01 Apr 2017 22:22:44 +0000
Subject: Re: [PATCH v2] nfc: don't be making arch specific unaligned decisions at driver level.
Message-Id: <20170401222244.GF22034@zurbaran.ger.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201701090839.5u37Hdez%fengguang.wu@intel.com>
 <20170109175222.3162-1-paul.gortmaker@windriver.com>
In-Reply-To: <20170109175222.3162-1-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: linux-kernel@vger.kernel.org, kbuild test robot <lkp@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-wireless@vger.kernel.org

Hi Paul,

On Mon, Jan 09, 2017 at 12:52:22PM -0500, Paul Gortmaker wrote:
> Currently ia64 fails building allmodconfig with variations of:
> 
>    In file included from drivers/nfc/nxp-nci/i2c.c:39:0:
>    ./include/linux/unaligned/access_ok.h:62:29: error: redefinition of ‘put_unaligned_be64’
>     static __always_inline void put_unaligned_be64(u64 val, void *p)
>                                 ^~~~~~~~~~~~~~~~~~
>    In file included from ./arch/ia64/include/asm/unaligned.h:5:0,
>                     from ./arch/ia64/include/asm/io.h:22,
>                     from ./arch/ia64/include/asm/smp.h:20,
>                     from ./include/linux/smp.h:59,
>                     from ./include/linux/topology.h:33,
>                     from ./include/linux/gfp.h:8,
>                     from ./include/linux/slab.h:14,
>                     from ./include/linux/resource_ext.h:19,
>                     from ./include/linux/acpi.h:26,
>                     from drivers/nfc/nxp-nci/i2c.c:28:
>    ./include/linux/unaligned/be_byteshift.h:65:20: note: previous definition of ‘put_unaligned_be64’ was here
>     static inline void put_unaligned_be64(u64 val, void *p)
>                        ^~~~~~~~~~~~~~~~~~
>    scripts/Makefile.build:293: recipe for target 'drivers/nfc/nxp-nci/i2c.o' failed
> 
> The easiest explanation for this is to look at the non-arch users in
> the following output:
> 
>    linux$git grep include.*access_ok.h
>    arch/arm64/crypto/crc32-arm64.c:#include <linux/unaligned/access_ok.h>
>    arch/cris/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    arch/m68k/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    arch/mn10300/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    arch/powerpc/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    arch/s390/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    arch/x86/include/asm/unaligned.h:#include <linux/unaligned/access_ok.h>
>    drivers/nfc/nfcmrvl/fw_dnld.c:#include <linux/unaligned/access_ok.h>
>    drivers/nfc/nxp-nci/firmware.c:#include <linux/unaligned/access_ok.h>
>    drivers/nfc/nxp-nci/i2c.c:#include <linux/unaligned/access_ok.h>
>    include/asm-generic/unaligned.h:# include <linux/unaligned/access_ok.h>
> 
> Note that nfc is essentially the only non-arch user in the above.
> When it forces use of access_ok.h, it will break any arch that has
> already selected be_byteshift.h (or other conflicting implementations)
> at the arch level.
> 
> The decision of what variant for unaligned access to use needs to be
> left to the arch level and not used at the driver level.  Since not
> all arch will have sourced asm/unaligned.h already, we need to call
> it out and then the arch can give us just the one definition that
> is needed.
> 
> See commit 064106a91be5 ("kernel: add common infrastructure for
> unaligned access") as a reference.
> 
> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> 
> [v2: explicitly include asm/uaccess.h since some arch won't be
>  getting any variant of an unaligned access header without it.
>  Build test allmodconfig on x86-64, i386, arm64, ia64. ]
> 
>  drivers/nfc/nfcmrvl/fw_dnld.c  | 2 +-
>  drivers/nfc/nxp-nci/firmware.c | 2 +-
>  drivers/nfc/nxp-nci/i2c.c      | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
This build issue is now fixed in nfc-next with a couple of different
patches.

Cheers,
Samuel.
