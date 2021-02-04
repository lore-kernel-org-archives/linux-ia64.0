From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 04 Feb 2021 08:39:11 +0000
Subject: Re: [PATCH] efi: ia64: move IA64-only declarations to new asm/efi.h header
Message-Id: <294348ae-c87a-3bc1-3593-e0c7982fe7d7@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118124913.1555-1-ardb@kernel.org>
 <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
 <CAMj1kXGMzrrEnNfv-cf+fG3snSMDuud48tX1pEZKst9jODkiQw@mail.gmail.com>
In-Reply-To: <CAMj1kXGMzrrEnNfv-cf+fG3snSMDuud48tX1pEZKst9jODkiQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>
Cc: linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>

Hi Ard!

On 2/4/21 9:33 AM, Ard Biesheuvel wrote:
> That is one aspect of it. Another aspect is that the lack of a
> asm/efi.h header created some problems in the past, given that all
> other EFI architectures do have it.
> 
> But the most important reason is really that arch-specific definitions
> for an obsolete architecture should not be visible in other builds.

I fully agree. I try to test your patches over the weekend. Since Tony
is not active anymore, we need to get the patches pulled in through
someone else's tree. Probably Arnd or Mike (both CC'ed).

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
