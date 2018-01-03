From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 03 Jan 2018 07:49:35 +0000
Subject: Re: [PATCH 16/67] powerpc: rename dma_direct_ to dma_nommu_
Message-Id: <CAMuHMdWYDz_jHNxQ-B8944520R-myzHkjkL1rKWUjA38inU7cw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
	<20171229081911.2802-17-hch@lst.de>
	<878tdgtwzp.fsf@concordia.ellerman.id.au>
	<CAMuHMdWWus2kNSOzS94k-3678826W1YjKwCWTquu3hBLZ80cvw@mail.gmail.com>
	<87h8s3cvel.fsf@concordia.ellerman.id.au>
In-Reply-To: <87h8s3cvel.fsf-W0DJWXSxmBNbyGPkN3NxC2scP1bn1w/D@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Cc: Linux MIPS Mailing List <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sparclinux <sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Linux-Arch <linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, the arch/x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, arcml <linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k <linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org>, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, "open list:METAG ARCHITECTURE" <linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, Cris <linux-cris-kernel-VrBV9hrLPhE@public.gmane.org>, Parisc List <linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, io

Hi Michael,

On Wed, Jan 3, 2018 at 7:24 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
>
>> On Tue, Jan 2, 2018 at 10:45 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
>>> Christoph Hellwig <hch@lst.de> writes:
>>>
>>>> We want to use the dma_direct_ namespace for a generic implementation,
>>>> so rename powerpc to the second best choice: dma_nommu_.
>>>
>>> I'm not a fan of "nommu". Some of the users of direct ops *are* using an
>>> IOMMU, they're just setting up a 1:1 mapping once at init time, rather
>>> than mapping dynamically.
>>>
>>> Though I don't have a good idea for a better name, maybe "1to1",
>>> "linear", "premapped" ?
>>
>> "identity"?
>
> I think that would be wrong, but thanks for trying to help :)
>
> The address on the device side is sometimes (often?) offset from the CPU
> address. So eg. the device can DMA to RAM address 0x0 using address
> 0x800000000000000.
>
> Identity would imply 0 = 0 etc.
>
> I think "bijective" is the correct term, but that's probably a bit
> esoteric.

OK, didn't know about the offset.
Then "linear" is what we tend to use, right?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
