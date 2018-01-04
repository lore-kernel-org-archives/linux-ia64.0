From: Christoph Hellwig <hch@lst.de>
Date: Thu, 04 Jan 2018 08:48:28 +0000
Subject: Re: [PATCH 16/67] powerpc: rename dma_direct_ to dma_nommu_
Message-Id: <20180104084828.GA3251@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
	<20171229081911.2802-17-hch@lst.de>
	<878tdgtwzp.fsf@concordia.ellerman.id.au>
	<CAMuHMdWWus2kNSOzS94k-3678826W1YjKwCWTquu3hBLZ80cvw@mail.gmail.com>
	<87h8s3cvel.fsf@concordia.ellerman.id.au>
	<CAMuHMdWYDz_jHNxQ-B8944520R-myzHkjkL1rKWUjA38inU7cw@mail.gmail.com>
	<CAGRGNgV+DnZAAtiE5oe8rxp4=_JHJrtSQc8F5jrgN0rgYKfwjA@mail.gmail.com>
In-Reply-To: <CAGRGNgV+DnZAAtiE5oe8rxp4=_JHJrtSQc8F5jrgN0rgYKfwjA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux MIPS Mailing List <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sparclinux <sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Linux-Arch <linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, the arch/x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>, arcml <linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, alpha <linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k <linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org>, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, "open list:METAG ARCHITECTURE" <linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Mailing List, Arm" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, Cris <linux-cris-kernel-VrBV9hrLPhE@public.gmane.org>, Parisc List <linux-parisc@vg>

On Wed, Jan 03, 2018 at 07:19:46PM +1100, Julian Calaby wrote:
> If this is indeed a linear mapping, can we just remove this and
> replace it with the new "generic" mapping being introduced by this
> patchset?

That is the long-term plan.  But as the powerpc one includes support
for non-coherent DMA it will have to wait for the next batch.
