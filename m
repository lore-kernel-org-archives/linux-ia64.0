From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 17 May 2003 21:09:27 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, May 17, 2003 at 01:36:01PM -0500, James Bottomley wrote:
> How would you feel about making this API change?

No problem.

> I take it you have a preference for using _to_cpu and _to_device
> call variants?

Thinking about it some, these could be confused with the direction of
DMA.

Would "dma_sync_for_device" and "dma_sync_for_cpu" fit better?

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html


