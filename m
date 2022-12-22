From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Thu, 22 Dec 2022 11:46:16 +0000
Subject: [PATCH 00/19] Introduce __xchg, non-atomic xchg
Message-Id: <20221222114635.1251934-1-andrzej.hajda@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org
Cc: Andrzej Hajda <andrzej.hajda@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Boqun Feng <boqun.feng@gmail.com>, Mark Rutland <mark.rutland@arm.com>

Hi all,

I hope there will be place for such tiny helper in kernel.
Quick cocci analyze shows there is probably few thousands places
where it could be useful.
I am not sure who is good person to review/ack such patches,
so I've used my intuition to construct to/cc lists, sorry for mistakes.
This is the 2nd approach of the same idea, with comments addressed[0].

The helper is tiny and there are advices we can leave without it, so
I want to present few arguments why it would be good to have it:

1. Code readability/simplification/number of lines:

Real example from drivers/net/ethernet/mellanox/mlx5/core/esw/qos.c:
-       previous_min_rate = evport->qos.min_rate;
-       evport->qos.min_rate = min_rate;
+       previous_min_rate = __xchg(evport->qos.min_rate, min_rate);

For sure the code is more compact, and IMHO more readable.

2. Presence of similar helpers in other somehow related languages/libs:

a) Rust[1]: 'replace' from std::mem module, there is also 'take'
    helper (__xchg(&x, 0)), which is the same as private helper in
    i915 - fetch_and_zero, see latest patch.
b) C++ [2]: 'exchange' from utility header.

If the idea is OK there are still 2 qestions to answer:

1. Name of the helper, __xchg follows kernel conventions,
    but for me Rust names are also OK.
2. Where to put the helper:
a) as in this patchset include/linux/non-atomic/xchg.h,
    proposed by Andy Shevchenko,
b) include/linux/utils.h ? any better name? Some kind
    of container for simple helpers.

Structure of the patchset:
17 patches releasing __xchg name from arch files
1 patch adding __xchg
1 patch adding users of __xchg

Arnd thanks for convienient set of cross compilers, it was very helpful.

So many words for so small helper :)

[0]: https://lore.kernel.org/lkml/Y5OFSvaYbv4XCxhE@smile.fi.intel.com/T/
[1]: https://doc.rust-lang.org/std/mem/index.html
[2]: https://en.cppreference.com/w/cpp/header/utility

Regards
Andrzej

Andrzej Hajda (19):
  arch/alpha: rename internal name __xchg to __arch_xchg
  arch/arc: rename internal name __xchg to __arch_xchg
  arch/arm: rename internal name __xchg to __arch_xchg
  arch/arm64: rename internal name __xchg to __arch_xchg
  arch/hexagon: rename internal name __xchg to __arch_xchg
  arch/ia64: rename internal name __xchg to __arch_xchg
  arch/loongarch: rename internal name __xchg to __arch_xchg
  arch/m68k: rename internal name __xchg to __arch_xchg
  arch/mips: rename internal name __xchg to __arch_xchg
  arch/openrisc: rename internal name __xchg to __arch_xchg
  arch/parisc: rename internal name __xchg to __arch_xchg
  arch/powerpc: correct logged function names in xchg helpers
  arch/riscv: rename internal name __xchg to __arch_xchg
  arch/s390: rename internal name __xchg to __arch_xchg
  arch/sh: rename internal name __xchg to __arch_xchg
  arch/sparc: rename internal name __xchg to __arch_xchg
  arch/xtensa: rename internal name __xchg to __arch_xchg
  linux/include: add non-atomic version of xchg
  drm/i915/gt: use __xchg instead of internal helper

 arch/alpha/include/asm/cmpxchg.h              |  6 +++---
 arch/arc/include/asm/cmpxchg.h                |  4 ++--
 arch/arm/include/asm/cmpxchg.h                |  4 ++--
 arch/arm64/include/asm/cmpxchg.h              |  4 ++--
 arch/hexagon/include/asm/cmpxchg.h            |  6 +++---
 arch/ia64/include/asm/cmpxchg.h               |  2 +-
 arch/ia64/include/uapi/asm/cmpxchg.h          |  4 ++--
 arch/loongarch/include/asm/cmpxchg.h          |  4 ++--
 arch/m68k/include/asm/cmpxchg.h               |  6 +++---
 arch/mips/include/asm/cmpxchg.h               |  4 ++--
 arch/openrisc/include/asm/cmpxchg.h           |  4 ++--
 arch/parisc/include/asm/cmpxchg.h             |  4 ++--
 arch/powerpc/include/asm/cmpxchg.h            |  4 ++--
 arch/riscv/include/asm/atomic.h               |  2 +-
 arch/riscv/include/asm/cmpxchg.h              |  4 ++--
 arch/s390/include/asm/cmpxchg.h               |  4 ++--
 arch/sh/include/asm/cmpxchg.h                 |  4 ++--
 arch/sparc/include/asm/cmpxchg_32.h           |  4 ++--
 arch/sparc/include/asm/cmpxchg_64.h           |  4 ++--
 arch/xtensa/include/asm/cmpxchg.h             |  4 ++--
 drivers/gpu/drm/i915/gt/intel_engine_cs.c     |  2 +-
 .../gpu/drm/i915/gt/intel_engine_heartbeat.c  |  4 ++--
 .../drm/i915/gt/intel_execlists_submission.c  |  4 ++--
 drivers/gpu/drm/i915/gt/intel_ggtt.c          |  4 ++--
 drivers/gpu/drm/i915/gt/intel_gsc.c           |  2 +-
 drivers/gpu/drm/i915/gt/intel_gt.c            |  4 ++--
 drivers/gpu/drm/i915/gt/intel_gt_pm.c         |  2 +-
 drivers/gpu/drm/i915/gt/intel_lrc.c           |  6 +++---
 drivers/gpu/drm/i915/gt/intel_migrate.c       |  2 +-
 drivers/gpu/drm/i915/gt/intel_rc6.c           |  2 +-
 drivers/gpu/drm/i915/gt/intel_rps.c           |  2 +-
 drivers/gpu/drm/i915/gt/selftest_context.c    |  2 +-
 .../drm/i915/gt/selftest_ring_submission.c    |  2 +-
 drivers/gpu/drm/i915/gt/selftest_timeline.c   |  2 +-
 drivers/gpu/drm/i915/gt/uc/intel_gsc_uc.c     |  2 +-
 drivers/gpu/drm/i915/gt/uc/intel_uc.c         |  2 +-
 drivers/gpu/drm/i915/gt/uc/intel_uc_fw.c      |  2 +-
 drivers/gpu/drm/i915/i915_utils.h             |  1 +
 include/linux/non-atomic/xchg.h               | 19 +++++++++++++++++++
 39 files changed, 84 insertions(+), 64 deletions(-)
 create mode 100644 include/linux/non-atomic/xchg.h

-- 
2.34.1
