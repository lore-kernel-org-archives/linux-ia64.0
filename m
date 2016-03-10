From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 10 Mar 2016 14:43:12 +0000
Subject: [PATCH v3 0/4] generic relative extable support
Message-Id: <1457620996-462-1-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is basically a resend of the remaining relative extable rework patches
that were queued for v4.6 in Andrew's tree for a couple of weeks, and then
subsequently dropped due to conflicts with the arm64 and x86 subtrees in -next.

Since the core patch that these remaining patches depend on is now queued in
the arm64 tree for inclusion in v4.6, I have rebased this series onto
next-20160310 so that they may be requeued and hopefully merged late during the
next merge window. Alternatively, they could be picked up by each maintainer
separately since they are all independent. Queueing them for v4.7 is likely
to result in conflicts again, so I think that would be the least preferable
option.

Changes since v2:
- dropped core patch and arm64 patches since they are already en route
- fixed up a purely contextual conflict in the x86 patch, the functional
  changes were completely independent

---- v2 blurb ----
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

Changes since v1:
- introduce the _ASM_EXTABLE() cpp macro for arm64, and replace all open coded
  exception table entries with it, including an instance I missed in v1 in
  asm/word-at-a-time.h (suggested by hpa)
- added acks to from arch maintainers

Ard Biesheuvel (4):
  alpha/extable: use generic search and sort routines
  s390/extable: use generic search and sort routines
  x86/extable: use generic search and sort routines
  ia64/extable: use generic search and sort routines

 arch/alpha/include/asm/uaccess.h |  10 +-
 arch/alpha/mm/Makefile           |   2 +-
 arch/alpha/mm/extable.c          |  92 -----------------
 arch/ia64/include/asm/uaccess.h  |   8 +-
 arch/ia64/mm/extable.c           |  97 +-----------------
 arch/s390/include/asm/uaccess.h  |   8 +-
 arch/s390/mm/Makefile            |   2 +-
 arch/s390/mm/extable.c           |  85 ---------------
 arch/x86/include/asm/uaccess.h   |   5 +-
 arch/x86/mm/extable.c            | 108 --------------------
 10 files changed, 17 insertions(+), 400 deletions(-)
 delete mode 100644 arch/alpha/mm/extable.c
 delete mode 100644 arch/s390/mm/extable.c

-- 
1.9.1

