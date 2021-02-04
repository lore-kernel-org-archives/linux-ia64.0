From: Ard Biesheuvel <ardb@kernel.org>
Date: Thu, 04 Feb 2021 08:33:55 +0000
Subject: Re: [PATCH] efi: ia64: move IA64-only declarations to new asm/efi.h header
Message-Id: <CAMj1kXGMzrrEnNfv-cf+fG3snSMDuud48tX1pEZKst9jODkiQw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118124913.1555-1-ardb@kernel.org> <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
In-Reply-To: <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

On Thu, 4 Feb 2021 at 09:26, John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> Hi Ard!
>
> On 1/18/21 1:49 PM, Ard Biesheuvel wrote:
> > Move some EFI related declarations that are only referenced on IA64 to
> > a new asm/efi.h arch header.
>
> I will test these changes later this week. I guess they will make it easier
> to drop ia64 support from the kernel if that gets decided in the foreseeable
> future.
>

Hi John,

That is one aspect of it. Another aspect is that the lack of a
asm/efi.h header created some problems in the past, given that all
other EFI architectures do have it.

But the most important reason is really that arch-specific definitions
for an obsolete architecture should not be visible in other builds.

-- 
Ard.
