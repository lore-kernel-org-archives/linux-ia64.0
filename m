From: Mark Maule <maule@sgi.com>
Date: Fri, 04 Feb 2005 21:31:58 +0000
Subject: [PATCH 2.6.11-rc2 0/3] altix: AGP bridge support for tioca chip
Message-Id: <20050204213158.16671.87679.94380@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

Signed-off-by: Mark Maule <maule@sgi.com>

thanks
Mark
