From: Grant Grundler <iod00d@hp.com>
Date: Sat, 17 Jan 2004 02:14:22 +0000
Subject: Re: dma restriction on Itanium 2
Message-Id: <20040117021422.GG18103@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
In-Reply-To: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 16, 2004 at 05:48:15PM -0800, Kallol Biswas wrote:
> We have been seeing a problem on itanium 2 running linux 2.4.21-4.EL 
> with our 10GB ethernet card.
> The error is PCI related. On PARISC systems the DMA address could not
> span page boundary due to hardware limitation,

Which HW limitation on parisc?
Are you talking about under HPUX?

Calling pci_map_single() can map up to 64-pages under parisc-linux.
(And that's a semi-arbitrary SW limit I designed into the implementation)
pci_alloc_consistent() has the same limitation since it uses
pci_map_single().

> do we have the same limitation on Itanium 2 systems also?

Under linux ZX1 DMA support has very similar constraints
HW-wise as PARISC *except* for 64-bit capable devices.
64-bit devices are not limited to 64-pages on ZX1.

> If the transmit or receive
> descriptors take more than a page then they should be aligned such a way
> that DMA does not happen over a page right?

transmit and recieve descriptors should be using memory allocated
with pci_alloc_consistent(). I'm not aware of any page boundary
limitation there. What's missing in 2.4.X is the ability
to set 64-bit attribute for PCI consistent memory.

grant
