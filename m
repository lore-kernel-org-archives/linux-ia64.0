From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 28 Apr 2023 09:27:06 +0000
Subject: [PATCH v2 0/5] fbdev: Use regular I/O function for framebuffers
Message-Id: <20230428092711.406-1-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

(was: fbdev: Move framebuffer I/O helpers to <asm/fb.h>)

Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
depends on the architecture, but they all come down to regular I/O
functions of similar names. So use the regular functions instead.

The first patch a simple whitespace cleanup.

Until now, <linux/fb.h> contained an include of <asm/io.h>. As this
will go away patches 2 to 4 prepare include statements in the various
drivers. Source files that use regular I/O helpers, such as readl(),
now include <linux/io.h>. Source files that use framebuffer I/O
helpers, such as fb_readl(), also include <linux/io.h>.

Patch 5 replaces the architecture-based if-else branching in 
<linux/fb.h> by define statements that map to Linux' I/O fucntions.

After this change has been merged and included in a few release
without complains, we can update the drivers to regular I/O functions
and remove the fbdev-specific defines.

The patchset has been built for a variety of platforms, such as x86-64,
arm, aarch64, ppc64, parisc, m64k, mips and sparc.

v2:
	* use Linux I/O helpers (Sam, Arnd)

Thomas Zimmermann (5):
  fbdev/matrox: Remove trailing whitespaces
  ipu-v3: Include <linux/io.h>
  fbdev: Include <linux/io.h> in various drivers
  fbdev: Include <linux/io.h> in drivers
  fbdev: Define framebuffer I/O from Linux' I/O functions

 drivers/gpu/ipu-v3/ipu-prv.h                |  1 +
 drivers/video/fbdev/arcfb.c                 |  1 +
 drivers/video/fbdev/arkfb.c                 |  1 +
 drivers/video/fbdev/aty/atyfb.h             |  2 +
 drivers/video/fbdev/aty/mach64_cursor.c     |  3 +-
 drivers/video/fbdev/chipsfb.c               |  1 +
 drivers/video/fbdev/cirrusfb.c              |  1 +
 drivers/video/fbdev/core/cfbcopyarea.c      |  2 +-
 drivers/video/fbdev/core/cfbfillrect.c      |  2 +
 drivers/video/fbdev/core/cfbimgblt.c        |  2 +
 drivers/video/fbdev/core/fbmem.c            |  1 +
 drivers/video/fbdev/core/svgalib.c          |  2 +-
 drivers/video/fbdev/hgafb.c                 |  2 +-
 drivers/video/fbdev/hitfb.c                 |  2 +-
 drivers/video/fbdev/kyro/fbdev.c            |  2 +-
 drivers/video/fbdev/matrox/matroxfb_accel.c |  8 ++-
 drivers/video/fbdev/matrox/matroxfb_base.h  |  6 +-
 drivers/video/fbdev/pm2fb.c                 |  1 +
 drivers/video/fbdev/pm3fb.c                 |  1 +
 drivers/video/fbdev/pvr2fb.c                |  1 +
 drivers/video/fbdev/s3fb.c                  |  1 +
 drivers/video/fbdev/sstfb.c                 |  2 +-
 drivers/video/fbdev/tdfxfb.c                |  2 +-
 drivers/video/fbdev/tridentfb.c             |  1 +
 drivers/video/fbdev/vga16fb.c               |  2 +-
 drivers/video/fbdev/vt8623fb.c              |  1 +
 drivers/video/fbdev/wmt_ge_rops.c           |  2 +
 include/linux/fb.h                          | 63 +++++----------------
 28 files changed, 52 insertions(+), 64 deletions(-)

-- 
2.40.0
