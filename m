From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 15:50:39 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Thu, 15 May 2003 10:05:28 -0500, Colin Ngam <cngam@sgi.com> said:
>
>   Colin> I do not know whether using the same set of flags i.e.GFP_XXX
>   Colin> would overload it's meanings to other MM routines but I
>   Colin> really like the a flag parameter, that will provide
>   Colin> capability for Platform specific hints.
>
> Overloading the GFP flags with platform-specific DMA stuff is certainly
> not an option.
>
> If you want to argue for yet-another-flags argument, go ahead and do
> so.  Be prepared for having to make a VERY strong argument...

David,

I was argueing for using the flag arguement and define it's own set
of values versus using the GFP_XXX defines.  And not an additional
flag arguement.

Thanks.

colin

>
>
>         --david


