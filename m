From: James Bottomley <James.Bottomley@steeleye.com>
Date: Sun, 18 May 2003 17:49:49 +0000
Subject: Re: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-05-18 at 12:22, Grant Grundler wrote:
> On Sun, May 18, 2003 at 09:43:41AM +0000, Arjan van de Ven wrote:
> > Most drivers will just say "look I
> > can do THIS much. I don't give a flying fish about how much of
> > that you actually use". At least in the probing code. 
> 
> The platform code needs a way to indicate the given mask will not work.
> Rejecting proposals by the driver seems reasonable if the driver
> only supports two different masks anyway (eg 64 and 32-bit).
> 
> In the case of a platform requiring 64-bit masks for consistent mappings,
> the platform DMA code must reject proposals for non-64-bit DMA masks.
> (eg PCI-X device implementing less than 64-bits)
> 
> In both cases the driver will care because it will crash the box otherwise.

In that case, the platform returns zero to "this much" being less than
the full 64 bits implying there's no mask the platform and driver can
agree on.

James



