From: Ard Biesheuvel <ardb@kernel.org>
Date: Thu, 04 Feb 2021 08:40:25 +0000
Subject: Re: [PATCH] efi: ia64: move IA64-only declarations to new asm/efi.h header
Message-Id: <CAMj1kXEOR5d7Hva7_=RkaoZw9A3ZBe-6otAL-C9YvL7FHe9+NQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118124913.1555-1-ardb@kernel.org> <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
 <CAMj1kXGMzrrEnNfv-cf+fG3snSMDuud48tX1pEZKst9jODkiQw@mail.gmail.com> <294348ae-c87a-3bc1-3593-e0c7982fe7d7@physik.fu-berlin.de>
In-Reply-To: <294348ae-c87a-3bc1-3593-e0c7982fe7d7@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>

On Thu, 4 Feb 2021 at 09:39, John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> Hi Ard!
>
> On 2/4/21 9:33 AM, Ard Biesheuvel wrote:
> > That is one aspect of it. Another aspect is that the lack of a
> > asm/efi.h header created some problems in the past, given that all
> > other EFI architectures do have it.
> >
> > But the most important reason is really that arch-specific definitions
> > for an obsolete architecture should not be visible in other builds.
>
> I fully agree. I try to test your patches over the weekend. Since Tony
> is not active anymore, we need to get the patches pulled in through
> someone else's tree. Probably Arnd or Mike (both CC'ed).
>

Actually, I have already sent this patch via the EFI tree, and it is
already in -next.
