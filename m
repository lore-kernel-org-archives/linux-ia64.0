From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Tue, 21 Jun 2022 19:15:45 +0000
Subject: [PATCH v4 0/8] bitops: let optimize out non-atomic bitops on compile-time constants
Message-Id: <20220621191553.69455-1-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

While I was working on converting some structure fields from a fixed
type to a bitmap, I started observing code size increase not only in
places where the code works with the converted structure fields, but
also where the converted vars were on the stack. That said, the
following code:

	DECLARE_BITMAP(foo, BITS_PER_LONG) = { }; // -> unsigned long foo[1];
	unsigned long bar = BIT(BAR_BIT);
	unsigned long baz = 0;

	__set_bit(FOO_BIT, foo);
	baz |= BIT(BAZ_BIT);

	BUILD_BUG_ON(!__builtin_constant_p(test_bit(FOO_BIT, foo));
	BUILD_BUG_ON(!__builtin_constant_p(bar & BAR_BIT));
	BUILD_BUG_ON(!__builtin_constant_p(baz & BAZ_BIT));

triggers the first assertion on x86_64, which means that the
compiler is unable to evaluate it to a compile-time initializer
when the architecture-specific bitop is used even if it's obvious.
I found that this is due to that many architecture-specific
non-atomic bitop implementations use inline asm or other hacks which
are faster or more robust when working with "real" variables (i.e.
fields from the structures etc.), but the compilers have no clue how
to optimize them out when called on compile-time constants.

So, in order to let the compiler optimize out such cases, expand the
test_bit() and __*_bit() definitions with a compile-time condition
check, so that they will pick the generic C non-atomic bitop
implementations when all of the arguments passed are compile-time
constants, which means that the result will be a compile-time
constant as well and the compiler will produce more efficient and
simple code in 100% cases (no changes when there's at least one
non-compile-time-constant argument).
The condition itself:

if (
__builtin_constant_p(nr) &&	/* <- bit position is constant */
__builtin_constant_p(!!addr) &&	/* <- compiler knows bitmap addr is
				      always either NULL or not */
addr &&				/* <- bitmap addr is not NULL */
__builtin_constant_p(*addr)	/* <- compiler knows the value of
				      the target bitmap */
)
	/* then pick the generic C variant
else
	/* old code path, arch-specific

I also tried __is_constexpr() as suggested by Andy, but it was
always returning 0 ('not a constant') for the 2,3 and 4th
conditions.

The object code size changes are architecture, compiler and compiler
flags dependent, there could be 80 Kb saved in one case and then 5
Kb added in another, but what most important is that the bitops are
now often transparent for the compilers, e.g. the following:

	DECLARE_BITMAP(flags, __IP_TUNNEL_FLAG_NUM) = { };
	__be16 flags;

	__set_bit(IP_TUNNEL_CSUM_BIT, flags);

	tun_flags = cpu_to_be16(*flags & U16_MAX);

	if (test_bit(IP_TUNNEL_VTI_BIT, flags))
		tun_flags |= VTI_ISVTI;

	BUILD_BUG_ON(!__builtin_constant_p(tun_flags));

doesn't blow up anymore (which is being checked now at build time),
so that we can now e.g. use fixed bitmaps in compile-time assertions
etc.

The series has been in intel-next for a while with no reported issues.

From v3[0]:
* fix a typo in the comment in 0006 (Andy);
* pick more Reviewed-bys (Andy, Marco);
* don't assume compiler expands small mem*() builtins in bitmap_*()
  (me, with a small hint from lkp).

From v2[1]:
* collect several Reviewed-bys (Andy, Yury);
* add a comment to generic_test_bit() that it is atomic-safe and
  must always stay like that (the first version of this series
  erroneously tried to change this) (Andy, Marco);
* unify the way how architectures define platform-specific bitops,
  both supporting instrumentation and not: now they define only
  'arch_' versions and asm-generic includes take care of the rest;
* micro-optimize the diffstat of 0004/0007 (__check_bitop_pr())
  (Andy);
* add compile-time tests to lib/test_bitmap to make sure everything
  works as expected on any setup (Yury).

From v1[2]:
* change 'gen_' prefixes to '_generic' to disambiguate from
  'generated' etc. (Mark);
* define a separate 'const_' set to use in the optimization to keep
  the generic test_bit() atomic-safe (Marco);
* unify arch_{test,__*}_bit() as well and include them in the type
  check;
* add more relevant and up-to-date bloat-o-meter results, including
  ARM64 (me, Mark);
* pick a couple '*-by' tags (Mark, Yury).

Also available on my open GH[3].

[0] https://lore.kernel.org/linux-arch/20220617144031.2549432-1-alexandr.lobakin@intel.com
[1] https://lore.kernel.org/linux-arch/20220610113427.908751-1-alexandr.lobakin@intel.com
[2] https://lore.kernel.org/all/20220606114908.962562-1-alexandr.lobakin@intel.com
[3] https://github.com/alobakin/linux/commits/bitops

Alexander Lobakin (8):
  ia64, processor: fix -Wincompatible-pointer-types in ia64_get_irr()
  bitops: always define asm-generic non-atomic bitops
  bitops: unify non-atomic bitops prototypes across architectures
  bitops: define const_*() versions of the non-atomics
  bitops: wrap non-atomic bitops with a transparent macro
  bitops: let optimize out non-atomic bitops on compile-time constants
  bitmap: don't assume compiler evaluates small mem*() builtins calls
  lib: test_bitmap: add compile-time optimization/evaluations assertions

 arch/alpha/include/asm/bitops.h               |  32 ++--
 arch/hexagon/include/asm/bitops.h             |  24 ++-
 arch/ia64/include/asm/bitops.h                |  42 ++---
 arch/ia64/include/asm/processor.h             |   2 +-
 arch/m68k/include/asm/bitops.h                |  49 ++++--
 arch/sh/include/asm/bitops-op32.h             |  34 ++--
 arch/sparc/include/asm/bitops_32.h            |  18 +-
 arch/sparc/lib/atomic32.c                     |  12 +-
 arch/x86/include/asm/bitops.h                 |  22 +--
 .../asm-generic/bitops/generic-non-atomic.h   | 161 ++++++++++++++++++
 .../bitops/instrumented-non-atomic.h          |  35 ++--
 include/asm-generic/bitops/non-atomic.h       | 121 +------------
 .../bitops/non-instrumented-non-atomic.h      |  16 ++
 include/linux/bitmap.h                        |  22 ++-
 include/linux/bitops.h                        |  50 ++++++
 lib/test_bitmap.c                             |  45 +++++
 tools/include/asm-generic/bitops/non-atomic.h |  34 ++--
 tools/include/linux/bitops.h                  |  16 ++
 18 files changed, 495 insertions(+), 240 deletions(-)
 create mode 100644 include/asm-generic/bitops/generic-non-atomic.h
 create mode 100644 include/asm-generic/bitops/non-instrumented-non-atomic.h

-- 
2.36.1
