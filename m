From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 13 Aug 2014 10:28:50 +0000
Subject: [PATCH v4 0/8] asm-generic/io.h overhaul
Message-Id: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Hi,

Here is the fourth version of a series that started out as an attempt to
provide string versions of the read*() and write*() accessors to more
architectures so that drivers can use them portably. The series has
since evolved into a more general cleanup of asm-generic/io.h and the
functions defined therein.

Patch 1 is trivial and removes a redundant redefinition of PCI_IOBASE
from the asm/io.h header on ARC. Patches 2 and 3 remove unnecessary
volatile keywoards from some functions, which is a prerequisite to clean
up some of the functions in subsequent patches.

The xlate_dev_{kmem,mem}_ptr() functions are used to map memory when the
/dev/mem device is accessed. Patches 4 and 5 use more consistent data
types for these functions, which will get a "standard" prototype in the
asm-generic/io.h header in a subsequent patch.

Patch 6 is the bulk of this series. It implements the string variants of
the read*() and write*() accessors and cleans up various other parts of
the asm-generic/io.h header file. Macros are converted to static inline
functions for better type checking. Overriding generic implementations
in architectures is handled more consistently.

Patches 7 and 8, finally, make use of the asm-generic/io.h header on the
32-bit and 64-bit ARM architectures.

This is compile- and runtime-tested on 32-bit and 64-bit ARM and compile
tested on IA64, Microblaze, s390, SPARC, x86 and Xtensa. For ARC,
Blackfin, Metag, OpenRISC, Score and Unicore32 which also use
asm-generic/io.h I couldn't find or build a cross-compiler that would
run on my system. But by code inspection they shouldn't break with this
patch.

To ensure bisectability I built multi_v7_defconfig on 32-bit ARM and the
defconfig for 64-bit ARM, IA64, Microblaze, s390, SPARC, x86 and Xtensa
after each commit and verified that the series does not introduce any
build errors or warnings.

Provided there are no objections to the patches there's still the matter
of how to merge them. Patch 6 depends on patches 1-5 to avoid warnings
and/or errors during the build. Patches 7 and 8 depend on patch 6. In my
opinion it doesn't make much sense to split them up, so I guess we'll
need a volunteer to take them all into one tree. Ideally that tree would
feed into linux-next so that we can get as much build and test-coverage
as possible during the 3.17 release cycle so that these patches can go
into 3.18.

Arnd, I'm opportunistically sending this To: you in the hopes that you
can take it into your asm-generic tree which seems like the best fit for
this.

Thierry

Thierry Reding (8):
  ARC: Remove redundant PCI_IOBASE declaration
  serial: sunzilog: Remove unnecessary volatile keyword
  sparc: Remove unnecessary volatile usage
  [IA64] Change xlate_dev_{kmem,mem}_ptr() prototypes
  /dev/mem: Use more consistent data types
  asm-generic/io.h: Implement generic {read,write}s*()
  ARM: Use include/asm-generic/io.h
  arm64: Use include/asm-generic/io.h

 arch/arc/include/asm/io.h       |   2 -
 arch/arm/include/asm/io.h       |  75 ++---
 arch/arm/include/asm/memory.h   |   2 +
 arch/arm64/Kconfig              |   1 -
 arch/arm64/include/asm/io.h     | 122 ++-----
 arch/arm64/include/asm/memory.h |   2 +
 arch/ia64/include/asm/uaccess.h |  16 +-
 arch/s390/include/asm/io.h      |   5 +-
 arch/s390/mm/maccess.c          |   4 +-
 arch/sparc/include/asm/io_32.h  |  18 +-
 arch/x86/include/asm/io.h       |   4 +-
 arch/x86/mm/ioremap.c           |   4 +-
 drivers/char/mem.c              |  13 +-
 drivers/tty/serial/sunzilog.h   |   8 +-
 include/asm-generic/io.h        | 683 ++++++++++++++++++++++++++++++++--------
 15 files changed, 647 insertions(+), 312 deletions(-)

-- 
2.0.4

