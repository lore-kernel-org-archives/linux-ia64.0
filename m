From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 09:19:04 +0000
Subject: Re: Altix I/O code reorganization - 8 of 21
Message-Id: <20040812101904.F5988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408112330.i7BNUK54163392@fsgi900.americas.sgi.com>
In-Reply-To: <200408112330.i7BNUK54163392@fsgi900.americas.sgi.com>; from pfg@sgi.com on Wed, Aug 11, 2004 at 06:30:20PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, hch@infradead.org

On Wed, Aug 11, 2004 at 06:30:20PM -0500, Pat Gefre wrote:
> > 004-pci-bridge_drivers:
> >    You still have code dealing with all kinds of PCIIO_ and PCIBR_ flags
> >    that will never be set through the Linux interfaces.  Again see the DMA
> >    mapping code I sent you.
> > 
> 
> The PCIIO_ flags are designed for usage at the Device Driver layer, 
> while the PCIBR_ flags are designed to be the actual hardware bits that needed 
> setting.  However, with the latest code, we have deleted the PCIIO_ and 
> PCIBR_ flags that are not used.

There still are tons that are used in the code, but never logically set from
the exported interfaces.

