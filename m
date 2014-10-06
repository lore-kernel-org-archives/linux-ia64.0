From: Thierry Reding <thierry.reding@gmail.com>
Date: Mon, 06 Oct 2014 13:52:32 +0000
Subject: [PATCH v5 0/9] asm-generic/io.h overhaul
Message-Id: <1412603561-27653-1-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Hi,

Here is the fifth version of a series that started out as an attempt to
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

Patch 6 is the bulk of this series. It cleans up various parts of the
asm-generic/io.h header file. Macros are converted to static inline
functions for better type checking. Overriding generic implementations
in architectures is handled more consistently.

Patch 7 implements the string variants of the read*() and write*()
accessors.

Patches 8 and 9, finally, make use of the asm-generic/io.h header on the
32-bit and 64-bit ARM architectures.

This is compile- and runtime-tested on 32-bit and 64-bit ARM and compile
tested on IA64, Microblaze, s390, SPARC, x86 and Xtensa. For ARC,
Blackfin, Metag, OpenRISC, Score and Unicore32 which also use
asm-generic/io.h I couldn't find or build a cross-compiler that would
run on my system. But by code inspection they shouldn't break with this
patch.

I'm sending this to Olof and Fengguang in the hopes that they can help
in getting more compile coverage of the series. I've uploaded the series
to a branch here[0]. Are there instructions somewhere on how to submit a
branch to your builder? If possible it would also be nice to get the
series tested for possible bisectability issues.

[0]: https://github.com/thierryreding/linux.git#asm-generic-io

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

