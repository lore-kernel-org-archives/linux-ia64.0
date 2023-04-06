From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Thu, 06 Apr 2023 14:30:00 +0000
Subject: [PATCH v2 00/19] arch: Consolidate <asm/fb.h>
Message-Id: <20230406143019.6709-1-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

Various architectures provide <arm/fb.h> with helpers for fbdev
framebuffer devices. Share the contained code where possible. There
is already <asm-generic/fb.h>, which implements generic (as in
'empty') functions of the fbdev helpers. The header was added in
commit aafe4dbed0bf ("asm-generic: add generic versions of common
headers"), but never used.

Each per-architecture header file declares and/or implements fbdev
helpers and defines a preprocessor token for each. The generic
header then provides the remaining helpers. It works like the I/O
helpers in <asm/io.h>.

For PARISC, the architecture helpers are mixed up with helpers
for the system's STI graphics firmware. We first move the STI code
to appropriate locations under video/ and then move the architecture
helper under arch/parisc.

For Sparc, there's an additional patch that moves the implementation
from the header into a source file. This allows to avoid some include
statements in the header file.

Built on arm, arm64, m68k, mips, parisc, powerpc, sparc and x86.

v2:
	* make writecombine the default mapping mode (Arnd)
	* rework fb_pgprotect() on m68k

Thomas Zimmermann (19):
  fbdev: Prepare generic architecture helpers
  arch/arc: Implement <asm/fb.h> with generic helpers
  arch/arm: Implement <asm/fb.h> with generic helpers
  arch/arm64: Implement <asm/fb.h> with generic helpers
  arch/ia64: Implement <asm/fb.h> with generic helpers
  arch/loongarch: Implement <asm/fb.h> with generic helpers
  arch/m68k: Merge variants of fb_pgprotect() into single function
  arch/m68k: Implement <asm/fb.h> with generic helpers
  arch/mips: Implement <asm/fb.h> with generic helpers
  video: Remove trailing whitespaces
  video: Move HP PARISC STI core code to shared location
  arch/parisc: Remove trailing whitespaces
  arch/parisc: Implement fb_is_primary_device() under arch/parisc
  arch/parisc: Implement <asm/fb.h> with generic helpers
  arch/powerpc: Implement <asm/fb.h> with generic helpers
  arch/sh: Implement <asm/fb.h> with generic helpers
  arch/sparc: Implement fb_is_primary_device() in source file
  arch/sparc: Implement <asm/fb.h> with generic helpers
  arch/x86: Implement <asm/fb.h> with generic helpers

 arch/arc/include/asm/fb.h                     |  11 +-
 arch/arm/include/asm/fb.h                     |  15 +-
 arch/arm64/include/asm/fb.h                   |  15 +-
 arch/ia64/include/asm/fb.h                    |  11 +-
 arch/loongarch/include/asm/fb.h               |  15 +-
 arch/m68k/include/asm/fb.h                    |  22 +--
 arch/mips/include/asm/fb.h                    |  10 +-
 arch/parisc/Makefile                          |   4 +-
 arch/parisc/include/asm/fb.h                  |  17 +-
 arch/parisc/video/Makefile                    |   3 +
 arch/parisc/video/fbdev.c                     |  27 +++
 arch/powerpc/include/asm/fb.h                 |   8 +-
 arch/sh/include/asm/fb.h                      |  15 +-
 arch/sparc/Makefile                           |   1 +
 arch/sparc/include/asm/fb.h                   |  26 +--
 arch/sparc/video/Makefile                     |   3 +
 arch/sparc/video/fbdev.c                      |  24 +++
 arch/x86/include/asm/fb.h                     |  11 +-
 drivers/video/Kconfig                         |   7 +
 drivers/video/Makefile                        |   1 +
 drivers/video/console/Kconfig                 |   1 +
 drivers/video/console/Makefile                |   4 +-
 drivers/video/console/sticon.c                |   6 +-
 drivers/video/fbdev/Kconfig                   |   3 +-
 drivers/video/fbdev/stifb.c                   | 158 +++++++++---------
 drivers/video/{console => }/sticore.c         | 123 ++++++--------
 include/asm-generic/fb.h                      |  23 ++-
 .../video/fbdev => include/video}/sticore.h   |  16 +-
 28 files changed, 289 insertions(+), 291 deletions(-)
 create mode 100644 arch/parisc/video/Makefile
 create mode 100644 arch/parisc/video/fbdev.c
 create mode 100644 arch/sparc/video/Makefile
 create mode 100644 arch/sparc/video/fbdev.c
 rename drivers/video/{console => }/sticore.c (95%)
 rename {drivers/video/fbdev => include/video}/sticore.h (99%)


base-commit: a7180debb9c631375684f4d717466cfb9f238660
prerequisite-patch-id: 0aa359f6144c4015c140c8a6750be19099c676fb
prerequisite-patch-id: c67e5d886a47b7d0266d81100837557fda34cb24
prerequisite-patch-id: d571861118316645b0124ac21260571720b632e2
prerequisite-patch-id: 15c0024c23be42851054ea840eec195f69716c08
prerequisite-patch-id: 441ee4341b183e4577c20a3f3bdebee529d21c34
prerequisite-patch-id: cbc453ee02fae02af22fbfdce56ab732c7a88c36
-- 
2.40.0
