From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 19 Feb 2014 16:06:07 +0000
Subject: [PATCH RFC/RFT v3 0/9] drivers: cacheinfo support
Message-Id: <1392825976-17633-1-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: sudeep.holla@arm.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

From: Sudeep Holla <sudeep.holla@arm.com>

Hi,

This series adds a generic cacheinfo support similar to topology. The
implementation is based on x86 cacheinfo support. Currently x86, powerpc,
ia64 and s390 have their own implementations. While adding similar support
to ARM and ARM64, here is the attempt to make it generic quite similar to
topology info support. It also adds the missing ABI documentation for
the cacheinfo sysfs which is already being used.

It moves all the existing different implementations on x86, ia64, powerpc
and s390 to use the generic cacheinfo infrastructure introduced here.
These changes on non-ARM platforms are only compile tested and hence
the request for testing too.

This series also adds support for ARM and ARM64 architectures based on
the generic support.

Changes v2[2]->v3:
	- Added new class "cpu" to group all cpu devices
	- Converted all "raw" kobjects used in cacheinfo to device_attr
	  by creating cache index devices
	- Added back s390 show_cacheinfo for /proc/cpuinfo
	- Added disable_sysfs to cache_info for preventing a cache node
	  to be exposed through sysfs if required(used on s390)

Changes v1[1]->v2[2]:
	- Extended the generic cacheinfo support to accomodate all
	  the existing implementations
	- Moved all the existing implementations to use this new
	  generic infrastructure
	- Added missing ABI documentation as suggested by Greg KH
	- Added support for unimplemented CTR on pre-ARMv6 implementations
	  as suggested by Russell. However the ctr_info_list is not yet
	  populated
	- not yet changed to device_attr as suggested by Greg KH,
	  registering cache as device won't eliminate the need of kobject
	  unless each index of cache is registered as a device which don't
	  seem to be good idea, but now it's unified it can be done easily
	  in one place if needed

[1] https://lkml.org/lkml/2014/1/8/523
[2] https://lkml.org/lkml/2014/2/7/654

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-arm-kernel@lists.infradead.org
---
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

 Documentation/ABI/testing/sysfs-devices-system-cpu |  40 +
 arch/arm/include/asm/outercache.h                  |  13 +
 arch/arm/kernel/Makefile                           |   1 +
 arch/arm/kernel/cacheinfo.c                        | 248 ++++++
 arch/arm/mm/Kconfig                                |  13 +
 arch/arm/mm/cache-l2x0.c                           |  14 +
 arch/arm/mm/cache-tauros2.c                        |  35 +
 arch/arm/mm/cache-xsc3l2.c                         |  15 +
 arch/arm64/kernel/Makefile                         |   2 +-
 arch/arm64/kernel/cacheinfo.c                      | 134 ++++
 arch/ia64/kernel/topology.c                        | 399 ++--------
 arch/powerpc/kernel/cacheinfo.c                    | 831 +++------------------
 arch/powerpc/kernel/cacheinfo.h                    |   8 -
 arch/powerpc/kernel/sysfs.c                        |   4 -
 arch/s390/kernel/cache.c                           | 388 +++-------
 arch/x86/kernel/cpu/intel_cacheinfo.c              | 647 ++++------------
 drivers/base/Makefile                              |   2 +-
 drivers/base/cacheinfo.c                           | 485 ++++++++++++
 drivers/base/core.c                                |  35 +-
 drivers/base/cpu.c                                 |   7 +
 include/linux/cacheinfo.h                          |  55 ++
 include/linux/cpu.h                                |   2 +
 22 files changed, 1523 insertions(+), 1855 deletions(-)
 create mode 100644 arch/arm/kernel/cacheinfo.c
 create mode 100644 arch/arm64/kernel/cacheinfo.c
 delete mode 100644 arch/powerpc/kernel/cacheinfo.h
 create mode 100644 drivers/base/cacheinfo.c
 create mode 100644 include/linux/cacheinfo.h

-- 
1.8.3.2

