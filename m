From: Waiman Long <longman@redhat.com>
Date: Mon, 11 Feb 2019 19:31:24 +0000
Subject: [PATCH v2 0/2] locking/rwsem: Remove arch specific rwsem files
Message-Id: <1549913486-16799-1-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

v2:
 - Add patch 2 to optimize __down_read_trylock() as suggested by PeterZ.
 - Update performance test data in patch 1.

This is part 0 of my rwsem patchset. It just removes the architecture
specific files to make it easer to add enhancements in the upcoming
rwsem patches.

Since the two ll/sc platforms that I can tested on (arm64 & ppc) are
both using the generic C codes, the rwsem performance shouldn't be
affected by this patch except the down_read_trylock() code which was
included in patch 2 for arm64.

Waiman Long (2):
  locking/rwsem: Remove arch specific rwsem files
  locking/rwsem: Optimize down_read_trylock()

 MAINTAINERS                     |   1 -
 arch/alpha/include/asm/rwsem.h  | 211 -----------------------------------
 arch/arm/include/asm/Kbuild     |   1 -
 arch/arm64/include/asm/Kbuild   |   1 -
 arch/hexagon/include/asm/Kbuild |   1 -
 arch/ia64/include/asm/rwsem.h   | 172 -----------------------------
 arch/powerpc/include/asm/Kbuild |   1 -
 arch/s390/include/asm/Kbuild    |   1 -
 arch/sh/include/asm/Kbuild      |   1 -
 arch/sparc/include/asm/Kbuild   |   1 -
 arch/x86/include/asm/rwsem.h    | 237 ----------------------------------------
 arch/x86/lib/Makefile           |   1 -
 arch/x86/lib/rwsem.S            | 156 --------------------------
 arch/xtensa/include/asm/Kbuild  |   1 -
 include/asm-generic/rwsem.h     | 140 ------------------------
 include/linux/rwsem.h           |   4 +-
 kernel/locking/percpu-rwsem.c   |   2 +
 kernel/locking/rwsem.h          | 130 ++++++++++++++++++++++
 18 files changed, 133 insertions(+), 929 deletions(-)
 delete mode 100644 arch/alpha/include/asm/rwsem.h
 delete mode 100644 arch/ia64/include/asm/rwsem.h
 delete mode 100644 arch/x86/include/asm/rwsem.h
 delete mode 100644 arch/x86/lib/rwsem.S
 delete mode 100644 include/asm-generic/rwsem.h

-- 
1.8.3.1
