From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 15:48:15 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On 15 May 2003 10:12:48 -0500, James Bottomley <James.Bottomley@HansenPartnership.com> said:
>
>   James> On Thu, 2003-05-15 at 10:06, David Mosberger wrote:
>   >> James and I have been discussing this very point for the last
>   >> week or so.  My preferred solution is to add an explicit dma-mask
>   >> argument to coherent/non-coherent allocators, but James prefers
>   >> to do this via a new GFP flag (GFP_DMA32 or some such).
>
>   James> This is still being hashed out.  It looks like adding a the
>   James> _mask variants may still be a viable runner for 2.6.

David,

Can you provide a little detail on how the _mask vriant is used and
passed into the call?

Thanks.

colin

>
>
> That would be good.
>
>         --david


