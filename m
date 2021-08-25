From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Wed, 25 Aug 2021 11:48:26 +0000
Subject: [PATCH 0/3] ia64: Miscellaneous fixes and cleanups
Message-Id: <cover.1629884459.git.geert+renesas@glider.be>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Simon Horman <horms@verge.net.au>, Tony Luck <tony.luck@intel.com>, Jay Lan <jlan@sgi.com>, Magnus Damm <magnus.damm@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, devicetree@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>

	Hi Andrew,

This patch series contains some miscellaneous fixes and cleanups for
ia64.  The second patch fixes a naming conflict triggered by a patch for
the FDT code.

This has been compile-tested only, due to lack of hardware.

Thanks!

Geert Uytterhoeven (3):
  ia64: Fix #endif comment for reserve_elfcorehdr()
  ia64: Make reserve_elfcorehdr() static
  ia64: Make num_rsvd_regions static

 arch/ia64/include/asm/meminit.h |  2 --
 arch/ia64/kernel/setup.c        | 53 ++++++++++++++++-----------------
 2 files changed, 26 insertions(+), 29 deletions(-)

-- 
2.25.1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
