From: Mike Rapoport <rppt@kernel.org>
Date: Sun, 12 Feb 2023 08:46:09 +0000
Subject: [PATCH 0/2] char/agp: consolidate asm/agp.h
Message-Id: <20230212084611.1311177-1-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Airlie <airlied@redhat.com>, "David S. Miller" <davem@davemloft.net>, Helge Deller <deller@gmx.de>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, dri-devel@lists.freedesktop.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, "Mike Rapoport (IBM)" <rppt@kernel.org>

From: "Mike Rapoport (IBM)" <rppt@kernel.org>

Hi,

asm/agp.h is duplicated in several architectures, with x86 being the
only instance that differs from the rest.

Introduce asm-generic/agp.h and use it instead of per-architecture
headers for the most cases.

I believe that asm-generic is the best tree to pick up this patches.

Mike Rapoport (IBM) (2):
  char/agp: consolidate {alloc,free}_gatt_pages()
  char/agp: introduce asm-generic/agp.h

 arch/alpha/include/asm/Kbuild   |  1 +
 arch/alpha/include/asm/agp.h    | 19 -------------------
 arch/ia64/include/asm/Kbuild    |  1 +
 arch/ia64/include/asm/agp.h     | 27 ---------------------------
 arch/parisc/include/asm/Kbuild  |  1 +
 arch/parisc/include/asm/agp.h   | 21 ---------------------
 arch/powerpc/include/asm/Kbuild |  1 +
 arch/powerpc/include/asm/agp.h  | 19 -------------------
 arch/sparc/include/asm/Kbuild   |  1 +
 arch/sparc/include/asm/agp.h    | 17 -----------------
 arch/x86/include/asm/agp.h      |  6 ------
 drivers/char/agp/agp.h          |  6 ++++++
 include/asm-generic/agp.h       | 11 +++++++++++
 13 files changed, 22 insertions(+), 109 deletions(-)
 delete mode 100644 arch/alpha/include/asm/agp.h
 delete mode 100644 arch/ia64/include/asm/agp.h
 delete mode 100644 arch/parisc/include/asm/agp.h
 delete mode 100644 arch/powerpc/include/asm/agp.h
 delete mode 100644 arch/sparc/include/asm/agp.h
 create mode 100644 include/asm-generic/agp.h


base-commit: 2241ab53cbb5cdb08a6b2d4688feb13971058f65
-- 
2.35.1
