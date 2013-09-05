From: Matt Fleming <matt@console-pimps.org>
Date: Thu, 05 Sep 2013 13:21:06 +0000
Subject: Re: [PATCH v4 0/3] Make commonly useful UEFI functions common
Message-Id: <20130905132106.GA7579@console-pimps.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1378377295-32758-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1378377295-32758-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, grant.likely@secretlab.ca, x86@kernel.org

On Thu, 05 Sep, at 11:34:52AM, Leif Lindholm wrote:
> This set breaks out some common code from x86/ia64 EFI support
> code and puts it into drivers/firmware/efi.
> 
> First it takes the definition of the global "efi" data structure
> and moves it into global efi.c. Then it implements a common version
> of efi_config_init().
> 
> Secondly it breaks the efi_lookup_mapped_addr() function out of x86
> and places it in global efi.c, for shared use with future ARM
> patches.
> 
> IA64 code compile tested only.
> 
> Leif Lindholm (3):
>   ia64: add early_memremap() alias for early_ioremap()
>   efi: x86: ia64: provide a generic efi_config_init()
>   efi: x86: make efi_lookup_mapped_addr() a common function
> 
>  arch/ia64/include/asm/io.h  |    1 +
>  arch/ia64/kernel/efi.c      |   54 ++++-------------
>  arch/x86/platform/efi/efi.c |  126 ++++----------------------------------
>  drivers/firmware/efi/efi.c  |  140 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/efi.h         |    8 +++
>  5 files changed, 170 insertions(+), 159 deletions(-)

Thanks Leif.

I've pulled this patch series into the 'arm/efi-stub' branch at,

  git://git.kernel.org/pub/scm/linux/kernel/git/mfleming/efi.git

as I know that Grant wanted these changes (and the subsequent patches)
in a clean branch.

Tip folks, how can we get the 'arm/efi-stub' branch into linux-next? My
plan was to merge 'arm/efi-stub' into my 'next' branch and ask you to
pull that into whichever branch you include in linux-next. Does that
work?

-- 
Matt Fleming, Intel Open Source Technology Center
