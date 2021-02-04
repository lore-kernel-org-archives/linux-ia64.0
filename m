From: Ard Biesheuvel <ardb@kernel.org>
Date: Thu, 04 Feb 2021 09:22:01 +0000
Subject: Re: [PATCH] efi: ia64: move IA64-only declarations to new asm/efi.h header
Message-Id: <CAMj1kXEDTLHyECC3yrfQ6Hgw1m9NB1GnNB=dO229To-goE6vmw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210118124913.1555-1-ardb@kernel.org> <f32b7560-4de4-79bb-a2e2-4edcb2a9d475@physik.fu-berlin.de>
 <CAMj1kXGMzrrEnNfv-cf+fG3snSMDuud48tX1pEZKst9jODkiQw@mail.gmail.com>
 <294348ae-c87a-3bc1-3593-e0c7982fe7d7@physik.fu-berlin.de>
 <CAMj1kXEOR5d7Hva7_=RkaoZw9A3ZBe-6otAL-C9YvL7FHe9+NQ@mail.gmail.com> <f8252e56-41ab-e89d-93bf-972cf0bc100b@physik.fu-berlin.de>
In-Reply-To: <f8252e56-41ab-e89d-93bf-972cf0bc100b@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>

On Thu, 4 Feb 2021 at 09:44, John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> On 2/4/21 9:40 AM, Ard Biesheuvel wrote:
> > Actually, I have already sent this patch via the EFI tree, and it is
> > already in -next.
>
> OK, I'll test it nonetheless and report back.
>

Thanks John.

Would you mind if I cc you in the future on EFI patches that may affect IA-64?
