From: Grant Grundler <iod00d@hp.com>
Date: Tue, 26 Oct 2004 18:12:58 +0000
Subject: Re: ia64 implementation of lib/iomap.c
Message-Id: <20041026181258.GH2728@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16759.51459.598187.91726@napali.hpl.hp.com>
In-Reply-To: <16759.51459.598187.91726@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 26, 2004 at 10:49:07AM -0700, Jesse Barnes wrote:
> What about the relaxed read then?  Should we have ioread_relaxed?
> I thought we had agreed that it was easier to assume relaxed semantics
> for ioread and add a dma_sync interface.

I would expect that requires fixing PCI drivers that depend on it.
Adding a dma_sync interface would probably make it easier to support
non-coherent (DMA and CPU caches are not coherent) platforms.

> Since PCI-X and PCI-Express have optional relaxed semantics that
> might make sense...

Jesse, you keep mixing up PCI-X Relaxed Ordering with readX() interface
and the two are NOT (directly) related.
The device driver can enable PCI-X Relaxed Ordering hints in general.
But the IO device controls "RO" hint use on individual bus transactions
it masters.

I'm not sure about PCI-Express (whole new bus protocol).

grant
