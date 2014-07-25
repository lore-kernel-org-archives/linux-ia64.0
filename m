From: Sudeep Holla <sudeep.holla@arm.com>
Date: Fri, 25 Jul 2014 16:44:43 +0000
Subject: [PATCH v2 0/9] drivers: cacheinfo support
Message-Id: <1406306692-7135-1-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1403717444-23559-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1403717444-23559-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: sudeep.holla@arm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

From: Sudeep Holla <sudeep.holla@arm.com>

This series adds a generic cacheinfo support similar to topology. The
implementation is based on x86 cacheinfo support. Currently x86, powerpc,
ia64 and s390 have their own implementations. While adding similar support
to ARM and ARM64, here is the attempt to make it generic quite similar to
topology info support. It also adds the missing ABI documentation for
the cacheinfo sysfs which is already being used.

It moves all the existing different implementations on x86, ia64, powerpc
and s390 to use the generic cacheinfo infrastructure introduced here.
These changes on non-ARM platforms are only compile tested and tested on x86.

This series also adds support for ARM and ARM64 architectures based on
the generic support.

Since there was no objection to the idea in RFC, I am posting non-RFC
version here.

The code can be fetched from:
 git://linux-arm.org/linux-skn cacheinfo


Changes v1->v2:
- removed custom device_{add,remove}_attrs, using is_visible callback
  instead(suggested by GregKH)
- arm64: changes as per MarkR review comments
- Moved smp_call_function_single to architectures using it(arm, arm64,
  x86) (suggested by Stephen Boyd)
- arm (mostly changes as per RMK's review comments)
	- fixed to allow v7 + v6 build
	- l2 cache changes to remove extra structure
	- populated CTR for few StrongARM CPU's not implementing CTR

Previous RFCs:
[1] https://lkml.org/lkml/2014/1/8/523
[2] https://lkml.org/lkml/2014/2/7/654
[3] https://lkml.org/lkml/2014/2/19/391

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org

Sudeep Holla (9):
  drivers: base: add new class "cpu" to group cpu devices
  drivers: base: support cpu cache information interface to userspace
    via sysfs
  ia64: move cacheinfo sysfs to generic cacheinfo infrastructure
  s390: move cacheinfo sysfs to generic cacheinfo infrastructure
  x86: move cacheinfo sysfs to generic cacheinfo infrastructure
  powerpc: move cacheinfo sysfs to generic cacheinfo infrastructure
  ARM64: kernel: add support for cpu cache information
  ARM: kernel: add support for cpu cache information
  ARM: kernel: add outer cache support for cacheinfo implementation

 Documentation/ABI/testing/sysfs-devices-system-cpu |  41 ++
 arch/arm/include/asm/outercache.h                  |   9 +
 arch/arm/kernel/Makefile                           |   1 +
 arch/arm/kernel/cacheinfo.c                        | 284 +++++++
 arch/arm/mm/Kconfig                                |  13 +
 arch/arm/mm/cache-l2x0.c                           |  35 +-
 arch/arm/mm/cache-tauros2.c                        |  35 +
 arch/arm/mm/cache-xsc3l2.c                         |  16 +
 arch/arm64/kernel/Makefile                         |   3 +-
 arch/arm64/kernel/cacheinfo.c                      | 142 ++++
 arch/ia64/kernel/topology.c                        | 401 ++--------
 arch/powerpc/kernel/cacheinfo.c                    | 813 +++------------------
 arch/powerpc/kernel/cacheinfo.h                    |   8 -
 arch/powerpc/kernel/sysfs.c                        |  12 +-
 arch/s390/kernel/cache.c                           | 388 +++-------
 arch/x86/kernel/cpu/intel_cacheinfo.c              | 680 +++++------------
 drivers/base/Makefile                              |   2 +-
 drivers/base/cacheinfo.c                           | 539 ++++++++++++++
 drivers/base/core.c                                |  39 +-
 drivers/base/cpu.c                                 |   7 +
 include/linux/cacheinfo.h                          |  73 ++
 include/linux/cpu.h                                |   2 +
 22 files changed, 1660 insertions(+), 1883 deletions(-)
 create mode 100644 arch/arm/kernel/cacheinfo.c
 create mode 100644 arch/arm64/kernel/cacheinfo.c
 delete mode 100644 arch/powerpc/kernel/cacheinfo.h
 create mode 100644 drivers/base/cacheinfo.c
 create mode 100644 include/linux/cacheinfo.h

-- 
1.8.3.2

