From: Grant Grundler <iod00d@hp.com>
Date: Sat, 17 May 2003 04:26:10 +0000
Subject: Re: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705920@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 16, 2003 at 04:40:25PM -0700, Jeremy Higdon wrote:
> -	/* pci_alloc_consistent gives only non-DAC addresses */
> -	test_desc.addr_hi = 0;
> +	test_desc.addr_hi = ((u64) buf_dma >> 32);
>  	test_desc.addr_lo = buf_dma & 0xffffffff;

Just curious, is the "& 0xffffffff" really necessary?
I was expecting "(u32) buf_dma" to be sufficient.

grant

