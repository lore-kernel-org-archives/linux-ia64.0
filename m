From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 07 Feb 2005 10:07:59 +0000
Subject: Re: [PATCH 2.6.11-rc2 0/3] altix: AGP bridge support for tioca chip
Message-Id: <20050207100759.GA11949@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
In-Reply-To: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 04, 2005 at 03:31:58PM -0600, Mark Maule wrote:
> This patchset provides new hardware support for the SGI TIOCA agp chip.
> 
> In order to stitch this into the SGI sn2 pci dma layer, it is necessary
> to add an abstraction which is implmented by PATCH 1/3 
> (sn2-pci-dma-abstraction.patch).
> 
> Additionally, a couple of header files were moved out of arch/ia64/sn
> and into include/asm-ia64/sn.  I also took the opportunity to kill some
> unused macros.  This is done by PATCH 2/3 (sn2-move-pci-headers.patch).
> 
> The TIOCA driver is implemented as an sn2 pci provider with hooks 
> externalized for an upcoming agpgart backend.  The TIOCA kernel driver is
> provided with PATCH 3/3 (sn2-tioca-driver.patch).

Wouldn't it be better to allow pluggable IOMMUs at the ia64 architecture
level, replacing the machvecs?

zx1 already has a switch to use swiotl for devices with too small dma
masks (and altix would need that one aswell if it tried to support such
devices).

