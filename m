From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 15:05:28 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705826@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Thu, 15 May 2003 08:17:58 -0500, Colin Ngam <cngam@sgi.com> said:
>
>   Colin> Anyway, to make a long story short, we like to "extend" these
>   Colin> interfaces to return DMA addresses of 64 bits if and when the
>   Colin> driver has the full capabality to support DAC - via it's DMA
>   Colin> mask capability setting.
>
>   Colin> This extention will not break current usages of these
>   Colin> interface, and as driver changes, this extension will enable
>   Colin> platforms to support all of it's Physical Memory via the
>   Colin> above 2 Interfaces without exhausting limited system mapping
>   Colin> resources.
>
> James and I have been discussing this very point for the last week or
> so.  My preferred solution is to add an explicit dma-mask argument to
> coherent/non-coherent allocators, but James prefers to do this via a
> new GFP flag (GFP_DMA32 or some such).

Hi David,

I actually like the flag as a parameter because it allows platform specific
extensions to pass in platform specific capabilities that can be ignored
by platform that does not support these capabilities.

I do not know whether using the same set of flags i.e.GFP_XXX would overload
it's meanings to other MM routines but I really like the a flag parameter, that
will provide capability for Platform specific hints.

Thanks.

Colin

>
>
>         --david


