From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 05 Jan 2016 15:19:34 +0000
Subject: [PATCH v2 0/6] generic relative extable support
Message-Id: <1452007180-27411-1-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, hpa@zytor.com, mingo@redhat.com, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mattst88@gmail.com, ink@jurassic.park.msu.ru, rth@twiddle.net, tony.luck@intel.com, fenghua.yu@intel.com, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de
Cc: deller@gmx.de, mark.rutland@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

There are currently four architectures (x86, ia64, alpha and s390) whose
user-access exception tables are relative to the table entry address rather
than absolute. Each of these architectures has its own search_extable() and
sort_extable() implementation, which are not only mostly identical to each
other, but also deviate very little from the generic absolute implementations
in lib/extable.c that they override.

So before making arm64 the fifth architecture that reimplements this, let's
refactor the existing code so that all of these architectures use common code
for searching and sorting the relative extables. Archs may set
ARCH_HAS_RELATIVE_EXTABLE to indicate that the table consists of a pair of
relative ints, and may define swap_ex_entry_fixup() if the fixup member needs
special treatment in the swapping step of the sorting routine (such as alpha).

Changes since v2:
- introduce the _ASM_EXTABLE() cpp macro for arm64, and replace all open coded
  exception table entries with it, including an instance I missed in v1 in
  asm/word-at-a-time.h (suggested by hpa)
- added acks to from arch maintainers

No acks yet for the arch/alpha patch.
 
NOTE: I took the liberty of carrying over each arch specific ack to the generic
shared first patch, since they are tightly coupled anyway. If anyone objects to
this, please let me know.

Also note that the s390 patch applies on top of the following patch:

  http://article.gmane.org/gmane.linux.kernel/2117036

which fixes a bug I spotted while working on this code. Since that probably
needs to go to -stable, I broke it out and posted it separately.

Ard Biesheuvel (6):
  extable: add support for relative extables to search and sort routines
  alpha/extable: use generic search and sort routines
  s390/extable: use generic search and sort routines
  x86/extable: use generic search and sort routines
  ia64/extable: use generic search and sort routines
  arm64: switch to relative exception tables

 arch/alpha/include/asm/uaccess.h        |  10 +-
 arch/alpha/mm/Makefile                  |   2 +-
 arch/alpha/mm/extable.c                 |  92 -----------------
 arch/arm64/include/asm/assembler.h      |  15 ++-
 arch/arm64/include/asm/futex.h          |  12 +--
 arch/arm64/include/asm/uaccess.h        |  30 +++---
 arch/arm64/include/asm/word-at-a-time.h |   7 +-
 arch/arm64/kernel/armv8_deprecated.c    |   7 +-
 arch/arm64/mm/extable.c                 |   2 +-
 arch/ia64/include/asm/uaccess.h         |   8 +-
 arch/ia64/mm/extable.c                  |  97 +-----------------
 arch/s390/include/asm/uaccess.h         |   8 +-
 arch/s390/mm/Makefile                   |   2 +-
 arch/s390/mm/extable.c                  |  85 ----------------
 arch/x86/include/asm/uaccess.h          |   5 +-
 arch/x86/mm/extable.c                   | 106 +-------------------
 lib/extable.c                           |  50 +++++++--
 scripts/sortextable.c                   |   2 +-
 18 files changed, 98 insertions(+), 442 deletions(-)
 delete mode 100644 arch/alpha/mm/extable.c
 delete mode 100644 arch/s390/mm/extable.c

-- 
2.5.0

