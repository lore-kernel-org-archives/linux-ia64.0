From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 27 Nov 2013 12:31:30 +0000
Subject: Re: [PATCH] firmware/dmi_scan: generalize for use by other archs
Message-Id: <CAKv+Gu9-BnWbCFuWSdavmBGDsP1qvEuCri9jHB=DWqwwnX9QnA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1385034003-32160-1-git-send-email-ard.biesheuvel@linaro.org>
	<CAKv+Gu9VbSLDOYnuGkuajSHmp2PMKE-hLS4X0Gu-KO=uhU9skg@mail.gmail.com>
	<20131127121231.968E6C404EC@trevor.secretlab.ca>
	<CACxGe6upu2yAeVRRjvLnnLctNYnUSaxR0gCp9WmtWHbco9hRUA@mail.gmail.com>
In-Reply-To: <CACxGe6upu2yAeVRRjvLnnLctNYnUSaxR0gCp9WmtWHbco9hRUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely@secretlab.ca>
Cc: "x86@kernel.org" <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Leif Lindholm <leif.lindholm@linaro.org>, Al Stone <al.stone@linaro.org>, Yi Li <yi.li@linaro.org>

On 27 November 2013 13:22, Grant Likely <grant.likely@secretlab.ca> wrote:
> On Wed, Nov 27, 2013 at 12:12 PM, Grant Likely
> <grant.likely@secretlab.ca> wrote:
>> On Mon, 25 Nov 2013 13:07:23 +0100, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>>> Hello all,
>>>
>>> Resending this patch to a slightly wider audience.
>>>
>>> The point of this patch is reworking the dmi_scan code slightly so it
>>> can be reused on ARM and arm64.
>>> There are no functional changes for x86 or IA-64, just one open
>>> question, i.e., whether the non-EFI fallback probe should be performed
>>> on IA-64 in the first place.
>>>
>>> If I could get acks for this patch please (if there are no
>>> objections), I will propose it to be merged through the ARM and/or
>>> arm64 trees as part of the complete series to enable SMBIOS.
>>>
>>> On 21 November 2013 12:40, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>>> > This patch makes a couple of changes to the SMBIOS/DMI scanning
>>> > code so it can be used on other archs (such as ARM and arm64):
>>> > (a) wrap the calls to ioremap()/iounmap(), this allows the use of a
>>> >     flavor of ioremap() more suitable for random unaligned access;
>>> > (b) allow the non-EFI fallback probe into hardcoded physical address
>>> >     0xF0000 to be disabled.
>>> >
>>> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>
>> Looks good.
>>
>> Reviewed-by: Grant Likely <grant.likely@linaro.org>
>
> Actually, I have one thought here...\
>
>>> >         } else {
>>> > -               p = dmi_ioremap(0xF0000, 0x10000);
>>> > +#ifdef DMI_SCAN_MACHINE_NON_EFI_FALLBACK
>>> > +               p = dmi_early_remap(0xF0000, 0x10000);
>>> >                 if (p = NULL)
>>> >                         goto error;
>>> >
>
> This is just ugly. #ifdef blocks inside of code is strongly
> discouraged. Instead, you can change the } else { line to:
>         } else if IS_ENABLED(CONFIG_DMI_NON_EFI_FALLBACK) {
>
> and then add an empty stanza to drivers/firmware/Kconfig:
>
> config DMI_NON_EFI_FALLBACK
>         bool
>
> And finally, make x86 and ia64 select it in arch/{ia64,x86}/Kconfig:
>
> config DMI
>         bool
>         select DMI_NON_EFI_FALLBACK
>         default y
>
> Which eliminates the DMI_SCAN_MACHINE_NON_EFI_FALLBACK #define from
> the header files.
>

I agree that this looks better. My approach was to make as few changes
to the x86 and ia64 code as possible, which included not introducing
new Kconfig symbols, especially as I can't easily test the ia64 build.

Will respin ...

Thanks,
Ard.
