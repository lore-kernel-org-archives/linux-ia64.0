From: Mark Maule <maule@sgi.com>
Date: Tue, 08 Feb 2005 00:08:10 +0000
Subject: [PATCH 2.6.11-rc2 0/3] altix: AGP bridge support for tioca chip
Message-Id: <20050208000810.10005.47319.70150@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
In-Reply-To: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resend of "altix: tioca chip driver (agp)" originally sent on 2005-02-04:

This patchset provides new hardware support for the SGI TIOCA agp chip.

In order to stitch this into the SGI sn2 pci dma layer, it is necessary
to add an abstraction which is implmented by PATCH 1/3 
(sn2-pci-dma-abstraction.patch).

Additionally, a couple of header files were moved out of arch/ia64/sn
and into include/asm-ia64/sn.  I also took the opportunity to kill some
unused macros.  This is done by PATCH 2/3 (sn2-move-pci-headers.patch).

The TIOCA driver is implemented as an sn2 pci provider with hooks 
externalized for an upcoming agpgart backend.  The TIOCA kernel driver is
provided with PATCH 3/3 (sn2-tioca-driver.patch).

Changes from first review:

sn2-pci-dma-abstraction.patch
	Use a local provider variable to improve readability

sn2-move-pci-headers.patch
	No changes

sn2-tioca-driver.patch
	Misc. style-related cleanups
	Remove unneeded casts
	Fix error-case memory leak
	Use list_for_each_entry() instead of list_for_each()
	Use list routines for dmamap management
	Move prom version checking to tioca_bus_fixup()

	Note:  I elected to leave the EXPORT_SYMBOL's alone as they
	are being used by our agpgart backend stub currently in
	development.  If we end up merging everything together as it looks
	like alpha does, then I'll yank 'em.  At a minimum, we should be
	able to remove tioca_gart_found and just count the elements
	in tioca_list.

thanks
Mark
