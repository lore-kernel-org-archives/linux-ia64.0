From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 15 May 2003 15:12:48 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705825@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2003-05-15 at 10:06, David Mosberger wrote:
> James and I have been discussing this very point for the last week or
> so.  My preferred solution is to add an explicit dma-mask argument to
> coherent/non-coherent allocators, but James prefers to do this via a
> new GFP flag (GFP_DMA32 or some such).

This is still being hashed out.  It looks like adding a the _mask
variants may still be a viable runner for 2.6.  If it turns out not to
be, the GFP_DMA32 will almost definitely be there.

James



