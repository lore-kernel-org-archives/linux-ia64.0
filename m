From: Grant Grundler <iod00d@hp.com>
Date: Thu, 15 May 2003 19:06:22 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 08:06:04AM -0700, David Mosberger wrote:
> James and I have been discussing this very point for the last week or
> so.  My preferred solution is to add an explicit dma-mask argument to
> coherent/non-coherent allocators, but James prefers to do this via a
> new GFP flag (GFP_DMA32 or some such).

For Streaming DMA, I'd rather stick with the current scheme.
The main reason is 64-bit addressing support will be hard coded
in the each driver as appropriate.  ie it's not a parameter than
needs to be passed in with each call to dma_map_single().

I'm assuming there is some performance impact to adding another argument
to the existing dma_* calls. (more instructions and another register
consumed). That might be a bad assumption for ia64.

Since Consistent DMA allocations aren't in the performance path normally,
implementation details here don't matter as much (to me).


One of the original goals for my talk at OLS was to propose extensions
to 2.4.x to provide "DMA Hints". This would help chipset specific DMA
support pick "optimal" settings for DMA operations.  I was thinking of
redefining "direction" parameter to be "hints".  It would continue to
support Read or Write "hint" but then use upper bits as flags for other
things (don't want to completely spoil my talk).  But I can't justify
the change based on the performance differences I've measured to date
and probably will not offer a proposal.  I haven't gotten to more complex
testing (only single card tests so far) and HPUX certainly saw performance
benefits in a similar scheme on PARISC (using PCI, not PCI-X).

hth,
grant

