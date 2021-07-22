From: Arnd Bergmann <arnd@kernel.org>
Date: Thu, 22 Jul 2021 12:48:05 +0000
Subject: [PATCH v3 0/6] asm-generic: strncpy_from_user/strnlen_user cleanup
Message-Id: <20210722124814.778059-1-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Al Viro <viro@zeniv.linux.org.uk>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Brian Cain <bcain@codeaurora.org>, Chris Zankel <chris@zankel.net>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoph Hellwig <hch@lst.de>, Guo Ren <guoren@kernel.org>, Heiko Carstens <hca@linux.ibm.com>, Helge Deller <deller@gmx.de>, Jeff Dike <jdike@addtoit.com>, Linus Walleij <linus.walleij@linaro.org>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek <monstr@monstr.eu>, Richard Weinberger <richard@nod.at>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Vasily Gorbik <gor@linux.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, uclinux-h8-devel@lists.sourceforge.jp

From: Arnd Bergmann <arnd@arndb.de>

I had run into some regressions for the previous version of this
series, the new version is based on v5.14-rc2 instead.

These two functions appear to be unnecessarily different between
architectures, and the asm-generic version is a bit questionable,
even for NOMMU architectures.

Clean this up to just use the generic library version for anything
that uses the generic version today. I've expanded on the patch
descriptions a little, as suggested by Christoph Hellwig, but I
suspect a more detailed review would uncover additional problems
with the custom versions that are getting removed.

I ended up adding patches for csky and microblaze as they had the
same implementation that I removed elsewhere, these are now gone
as well.

If I hear no objections from architecture maintainers or new
build regressions, I'll queue these up in the asm-generic tree
for 5.15.

       Arnd

Link: https://lore.kernel.org/linux-arch/20210515101803.924427-1-arnd@kernel.org/

Arnd Bergmann (9):
  asm-generic/uaccess.h: remove __strncpy_from_user/__strnlen_user
  h8300: remove stale strncpy_from_user
  hexagon: use generic strncpy/strnlen from_user
  arc: use generic strncpy/strnlen from_user
  csky: use generic strncpy/strnlen from_user
  microblaze: use generic strncpy/strnlen from_user
  asm-generic: uaccess: remove inline strncpy_from_user/strnlen_user
  asm-generic: remove extra strn{cpy_from,len}_user declarations
  asm-generic: reverse GENERIC_{STRNCPY_FROM,STRNLEN}_USER symbols

 arch/alpha/Kconfig                        |   2 -
 arch/arc/include/asm/uaccess.h            |  72 -------------
 arch/arc/mm/extable.c                     |  12 ---
 arch/arm/Kconfig                          |   2 -
 arch/arm64/Kconfig                        |   2 -
 arch/csky/include/asm/uaccess.h           |   6 --
 arch/csky/lib/usercopy.c                  | 102 ------------------
 arch/h8300/kernel/h8300_ksyms.c           |   2 -
 arch/h8300/lib/Makefile                   |   2 +-
 arch/h8300/lib/strncpy.S                  |  35 ------
 arch/hexagon/include/asm/uaccess.h        |  31 ------
 arch/hexagon/kernel/hexagon_ksyms.c       |   1 -
 arch/hexagon/mm/Makefile                  |   2 +-
 arch/hexagon/mm/strnlen_user.S            | 126 ----------------------
 arch/ia64/Kconfig                         |   2 +
 arch/m68k/Kconfig                         |   2 -
 arch/microblaze/include/asm/uaccess.h     |  19 +---
 arch/microblaze/kernel/microblaze_ksyms.c |   3 -
 arch/microblaze/lib/uaccess_old.S         |  90 ----------------
 arch/mips/Kconfig                         |   2 +
 arch/nds32/Kconfig                        |   2 -
 arch/nios2/Kconfig                        |   2 -
 arch/openrisc/Kconfig                     |   2 -
 arch/parisc/Kconfig                       |   2 +-
 arch/powerpc/Kconfig                      |   2 -
 arch/riscv/Kconfig                        |   2 -
 arch/s390/Kconfig                         |   2 +
 arch/sh/Kconfig                           |   2 -
 arch/sparc/Kconfig                        |   2 -
 arch/um/Kconfig                           |   2 +
 arch/um/include/asm/uaccess.h             |   5 +-
 arch/um/kernel/skas/uaccess.c             |  14 ++-
 arch/x86/Kconfig                          |   2 -
 arch/xtensa/Kconfig                       |   3 +-
 arch/xtensa/include/asm/uaccess.h         |   3 +-
 include/asm-generic/uaccess.h             |  52 ++-------
 lib/Kconfig                               |  10 +-
 37 files changed, 43 insertions(+), 581 deletions(-)
 delete mode 100644 arch/h8300/lib/strncpy.S
 delete mode 100644 arch/hexagon/mm/strnlen_user.S

-- 
2.29.2

Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com> 
Cc: Al Viro <viro@zeniv.linux.org.uk> 
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com> 
Cc: Brian Cain <bcain@codeaurora.org> 
Cc: Chris Zankel <chris@zankel.net> 
Cc: Christian Borntraeger <borntraeger@de.ibm.com> 
Cc: Christoph Hellwig <hch@lst.de>
Cc: Guo Ren <guoren@kernel.org> 
Cc: Heiko Carstens <hca@linux.ibm.com> 
Cc: Helge Deller <deller@gmx.de> 
Cc: Jeff Dike <jdike@addtoit.com> 
Cc: Linus Walleij <linus.walleij@linaro.org> 
Cc: Max Filippov <jcmvbkbc@gmail.com> 
Cc: Michal Simek <monstr@monstr.eu> 
Cc: Richard Weinberger <richard@nod.at> 
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de> 
Cc: Vasily Gorbik <gor@linux.ibm.com> 
Cc: Vineet Gupta <vgupta@synopsys.com> 
Cc: Yoshinori Sato <ysato@users.sourceforge.jp> 
Cc: linux-arch@vger.kernel.org 
Cc: linux-csky@vger.kernel.org 
Cc: linux-hexagon@vger.kernel.org 
Cc: linux-ia64@vger.kernel.org 
Cc: linux-kernel@vger.kernel.org 
Cc: linux-mips@vger.kernel.org 
Cc: linux-parisc@vger.kernel.org 
Cc: linux-s390@vger.kernel.org 
Cc: linux-snps-arc@lists.infradead.org 
Cc: linux-um@lists.infradead.org 
Cc: linux-xtensa@linux-xtensa.org 
Cc: uclinux-h8-devel@lists.sourceforge.jp 
