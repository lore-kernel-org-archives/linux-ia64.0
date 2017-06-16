From: Christoph Hellwig <hch@lst.de>
Date: Fri, 16 Jun 2017 08:39:07 +0000
Subject: Re: [PATCH 33/44] openrisc: remove arch-specific dma_supported implementation
Message-Id: <20170616083907.GB10582@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
	<20170608132609.32662-34-hch@lst.de>
	<CAMuHMdUPeFJJtz8eJkQEAR-2w9oHt-fXeGHvvKFLfU2A4YyviQ@mail.gmail.com>
In-Reply-To: <CAMuHMdUPeFJJtz8eJkQEAR-2w9oHt-fXeGHvvKFLfU2A4YyviQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Cc: Linux MIPS Mailing List <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, "linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-s390 <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-sh list <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org" <linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org>, the arch/x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, DRI Development <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sparclinux <sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev@lists.o>

On Fri, Jun 09, 2017 at 02:20:42PM +0200, Geert Uytterhoeven wrote:
> Hi Christoph,
> 
> On Thu, Jun 8, 2017 at 3:25 PM, Christoph Hellwig <hch@lst.de> wrote:
> > This implementation is simply bogus - hexagon only has a simple
> 
> openrisc?

Yeah.
