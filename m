From: Grant Grundler <iod00d@hp.com>
Date: Thu, 04 Dec 2003 19:04:51 +0000
Subject: Re: Problem booting Adaptec Ultra 320 driver with discontigmem support.
Message-Id: <marc-linux-ia64-107056489622661@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107054139923799@msgid-missing>
In-Reply-To: <marc-linux-ia64-107054139923799@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Dec 04, 2003 at 01:37:21PM +0100, Xavier Bru wrote:
> Hello, all
> 
> Running  2.6.0-test11 with Adaptec Ultra 320 driver that provides full 
> 64-bit support
> we hit a BUG in blk_queue_bounce_limit() due to physical address greater 
> than allowed by the dma mask.

Can the driver provide "full 64-bit support" if it's setting
the dma mask to something less than 64-bits?
Did you mean "full 40-bits DMA support"?

grant
