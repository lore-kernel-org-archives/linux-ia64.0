From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 22 Apr 2002 22:39:46 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905494@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Except that pci_alloc_consistent is supposed to return a 32 bit
address...

Jesse

On Mon, Apr 22, 2002 at 03:34:38PM -0700, David Mosberger wrote:
> >>>>> On Mon, 22 Apr 2002 15:31:56 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> Here's an implementation of the PCI DAC API for SN, along
>   Jesse> with some fixes to the existing implementation.  If this
>   Jesse> looks ok, I'd like it to get integrated into the next
>   Jesse> release, otherwise I'll fix it up.  Please take a look.
> 
> You do realize that there it is never necessary to use this API for
> ia64 linux?  dma_addr_t is already 64 bits.
> 
> 	--david

