From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Wed, 26 Apr 2023 13:04:15 +0000
Subject: [PATCH 0/5] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <20230426130420.19942-1-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
depends on the architecture. It's still all located in fbdev's main
header file <linux/fb.h>. Move all of it into each archtecture's
<asm/fb.h>, with shared code in <asm-generic/fb.h>.

The first patch a simple whitespace cleanup.

Until now, <linux/fb.h> contained an include of <asm/io.h>. As this
will go away patches 2 to 4 prepare include statements in the various
drivers. Source files that use regular I/O helpers, such as readl(),
now include <linux/io.h>. Source files that use framebuffer I/O
helpers, such as fb_readl(), now include <asm/fb.h>. The latter now
includes <linux/io.h> internally.

Patch 5 moves the framebuffer I/O helpers from <linux/fb.h> into
the various architecture headers. The common case, where the framebuffer
is located in I/O memory, serves as the generic implemenation.

The patchset has been built for a variety of platforms, such as x86-64,
arm, aarch64, ppc64, parisc, m64k, mips and sparc.

Thomas Zimmermann (5):
  fbdev/matrox: Remove trailing whitespaces
  ipu-v3: Include <linux/io.h>
  fbdev: Include <linux/io.h> in various drivers
  fbdev: Include <linux/io.h> via <asm/fb.h>
  fbdev: Move framebuffer I/O helpers into <asm/fb.h>

 arch/arc/include/asm/fb.h                   | 29 +++++++
 arch/ia64/include/asm/fb.h                  | 28 +++++++
 arch/loongarch/include/asm/fb.h             | 29 +++++++
 arch/m68k/include/asm/fb.h                  | 29 +++++++
 arch/sparc/include/asm/fb.h                 | 77 +++++++++++++++++
 drivers/gpu/ipu-v3/ipu-prv.h                |  1 +
 drivers/video/fbdev/arcfb.c                 |  1 +
 drivers/video/fbdev/arkfb.c                 |  2 +
 drivers/video/fbdev/aty/atyfb.h             |  2 +
 drivers/video/fbdev/aty/mach64_cursor.c     |  2 +-
 drivers/video/fbdev/chipsfb.c               |  1 +
 drivers/video/fbdev/cirrusfb.c              |  2 +
 drivers/video/fbdev/core/cfbcopyarea.c      |  2 +-
 drivers/video/fbdev/core/cfbfillrect.c      |  1 +
 drivers/video/fbdev/core/cfbimgblt.c        |  1 +
 drivers/video/fbdev/core/svgalib.c          |  3 +-
 drivers/video/fbdev/cyber2000fb.c           |  2 +
 drivers/video/fbdev/ep93xx-fb.c             |  2 +
 drivers/video/fbdev/hgafb.c                 |  3 +-
 drivers/video/fbdev/hitfb.c                 |  2 +-
 drivers/video/fbdev/kyro/fbdev.c            |  3 +-
 drivers/video/fbdev/matrox/matroxfb_accel.c |  8 +-
 drivers/video/fbdev/matrox/matroxfb_base.h  |  6 +-
 drivers/video/fbdev/pm2fb.c                 |  3 +
 drivers/video/fbdev/pm3fb.c                 |  2 +
 drivers/video/fbdev/pvr2fb.c                |  2 +
 drivers/video/fbdev/s3fb.c                  |  2 +
 drivers/video/fbdev/sm712fb.c               |  2 +
 drivers/video/fbdev/sstfb.c                 |  2 +-
 drivers/video/fbdev/stifb.c                 |  2 +
 drivers/video/fbdev/tdfxfb.c                |  3 +-
 drivers/video/fbdev/tridentfb.c             |  2 +
 drivers/video/fbdev/vga16fb.c               |  3 +-
 drivers/video/fbdev/vt8623fb.c              |  2 +
 drivers/video/fbdev/wmt_ge_rops.c           |  2 +
 include/asm-generic/fb.h                    | 93 +++++++++++++++++++++
 include/linux/fb.h                          | 53 ------------
 37 files changed, 340 insertions(+), 69 deletions(-)

-- 
2.40.0
