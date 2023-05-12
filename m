From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 12 May 2023 10:24:37 +0000
Subject: [PATCH v7 0/7] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <20230512102444.5438-1-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org, suijingfeng@loongson.cn
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
depends on the architecture, but they are all equivalent to regular
I/O functions of similar names. So use regular functions instead and
move all helpers into <asm-generic/fb.h>

The first two patch are driver cleanups.

Until now, <linux/fb.h> contained an include of <asm/io.h>. As this
will go away, patches 3 to 5 prepare include statements in the various
drivers. Source files that use regular I/O helpers, such as readl(),
now include <linux/io.h>. Source files that use framebuffer I/O
helpers, such as fb_readl(), now include <linux/fb.h>.

Patch 6 replaces the architecture-based if-else branching in 
<linux/fb.h> by helpers in <asm-generic/fb.h>. All helpers use Linux'
existing I/O functions.

Patch 7 harmonizes naming among fbdev and existing I/O functions.

The patchset has been built for a variety of platforms, such as x86-64,
arm, aarch64, ppc64, parisc, m64k, mips and sparc.

v7:
	* fix hitfb build warnings (kernel test robot)
v6:
	* fix build on 64-bit mips (kernel test robot)
	* update fb_io_fops.c
v5:
	* fix build on s390
v4:
	* keep fb_mem*() as-is on ia64, loongarch, sparc64 (Arnd)
	* don't include <asm/fb.h> (Sam)
v3:
	* add the new helpers in <asm-generic/fb.h>
	* support reordering and native byte order (Geert, Arnd)
v2:
	* use Linux I/O helpers (Sam, Arnd)

Thomas Zimmermann (7):
  fbdev/hitfb: Cast I/O offset to address
  fbdev/matrox: Remove trailing whitespaces
  ipu-v3: Include <linux/io.h>
  fbdev: Include <linux/io.h> in various drivers
  fbdev: Include <linux/fb.h> instead of <asm/fb.h>
  fbdev: Move framebuffer I/O helpers into <asm/fb.h>
  fbdev: Rename fb_mem*() helpers

 arch/ia64/include/asm/fb.h                  |  20 ++++
 arch/loongarch/include/asm/fb.h             |  21 ++++
 arch/mips/include/asm/fb.h                  |  22 ++++
 arch/parisc/video/fbdev.c                   |   3 +-
 arch/sparc/include/asm/fb.h                 |  20 ++++
 arch/sparc/video/fbdev.c                    |   1 -
 arch/x86/video/fbdev.c                      |   2 -
 drivers/gpu/ipu-v3/ipu-prv.h                |   1 +
 drivers/staging/sm750fb/sm750.c             |   2 +-
 drivers/video/fbdev/arcfb.c                 |   1 +
 drivers/video/fbdev/aty/atyfb.h             |   2 +
 drivers/video/fbdev/aty/mach64_cursor.c     |   2 +-
 drivers/video/fbdev/chipsfb.c               |   2 +-
 drivers/video/fbdev/core/fb_io_fops.c       |   4 +-
 drivers/video/fbdev/core/fbcon.c            |   1 -
 drivers/video/fbdev/core/fbmem.c            |   2 -
 drivers/video/fbdev/hitfb.c                 | 122 +++++++++++---------
 drivers/video/fbdev/kyro/fbdev.c            |   2 +-
 drivers/video/fbdev/matrox/matroxfb_accel.c |   6 +-
 drivers/video/fbdev/matrox/matroxfb_base.h  |   4 +-
 drivers/video/fbdev/pvr2fb.c                |   2 +-
 drivers/video/fbdev/sstfb.c                 |   2 +-
 drivers/video/fbdev/stifb.c                 |   4 +-
 drivers/video/fbdev/tdfxfb.c                |   2 +-
 drivers/video/fbdev/wmt_ge_rops.c           |   2 +
 include/asm-generic/fb.h                    | 102 ++++++++++++++++
 include/linux/fb.h                          |  55 +--------
 27 files changed, 279 insertions(+), 130 deletions(-)

-- 
2.40.1
