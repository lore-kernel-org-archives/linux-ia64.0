From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 01 Aug 2013 20:26:41 +0000
Subject: Re: [PATCH 0/4] Make commonly useful UEFI functions common
Message-Id: <51FAC481.2050905@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
In-Reply-To: <1375202858-28470-1-git-send-email-leif.lindholm@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leif Lindholm <leif.lindholm@linaro.org>
Cc: linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tglx@linutronix.de, patches@linaro.org, "Luck, Tony" <tony.luck@intel.com>

On 07/30/2013 09:47 AM, Leif Lindholm wrote:
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
> Pardon the delay in getting this out - back to back conferences
> followed by a bad case of the man flu.
> 
> Leif Lindholm (4):
>   efi: provide a generic efi_config_init()
>   efi: x86: use common code for (U)EFI configuration scanning
>   efi: ia64: use common code for (U)EFI configuration scanning
>   efi: x86: make efi_lookup_mapped_addr() a common function
> 
>  arch/ia64/include/asm/io.h  |    1 +
>  arch/ia64/kernel/efi.c      |   54 ++++-------------
>  arch/x86/platform/efi/efi.c |  124 +++------------------------------------
>  drivers/firmware/efi/efi.c  |  136 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/efi.h         |    7 +++
>  5 files changed, 163 insertions(+), 159 deletions(-)
> 

Matt, I assume you're picking this up once the missing bits are plugged
in, right?

	-hpa

