From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 04 Feb 2021 08:26:38 +0000
Subject: Re: [PATCH] efi: ia64: move IA64-only declarations to new asm/efi.h header
Message-Id: <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118124913.1555-1-ardb@kernel.org>
In-Reply-To: <20210118124913.1555-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>, linux-efi@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Hi Ard!

On 1/18/21 1:49 PM, Ard Biesheuvel wrote:
> Move some EFI related declarations that are only referenced on IA64 to
> a new asm/efi.h arch header.

I will test these changes later this week. I guess they will make it easier
to drop ia64 support from the kernel if that gets decided in the foreseeable
future.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
