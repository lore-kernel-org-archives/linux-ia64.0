From: Russell King <rmk@arm.linux.org.uk>
Date: Fri, 16 May 2003 18:18:04 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705904@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 16, 2003 at 01:13:07PM -0500, James Bottomley wrote:
> Well, it applies to partially coherent machines too.  However, the point
> of the API is to make it so that the driver writer doesn't need to
> understand where the calls go,  So the API encapsulates all the platform
> quirks in a simple set of rules of thumb.
> 
> Thus:
> 
>     map region
>     
>     Use region in driver
>     
>     dma_sync ... DMA_OWNER_DEVICE  .. and direction
>     
>     device uses region (driver may not touch it)
>     
>     dma_sync ... DMA_OWNER_CPU .. and direction
>     
>     driver accesses region again (may repeat back to use region in
>     driver)
>     
>     unmap region

Isn't the common use (eg, net devices):

	buffer passed from lower levels

	map buffer

	(device owns buffer)

	device uses buffer

	unmap buffer

	(cpu owns buffer)

	free buffer

So, to use your example:

	(cpu owns region)

	map

	(device owns region)

	dma_sync...cpu

	(cpu owns region)

	dma_sync...device

	(device owns region)

	unmap

	(cpu owns region)

Your suggestion seems to add in two extra sync calls (and thus extra code
in the common case.)

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html


