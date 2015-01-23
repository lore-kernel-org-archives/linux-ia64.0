From: al.stone@linaro.org
Date: Fri, 23 Jan 2015 00:44:37 +0000
Subject: [PATCH 0/7] Start deprecating _OSI on new architectures
Message-Id: <1421973884-13029-1-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, rjw@rjwysocki.net, catalin.marinas@arm.com, will.deacon@arm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, lenb@kernel.org, robert.moore@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, devel@acpica.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

The use of the ACPI _OSI method in Linux has a long and sordid history.
Instead of perpetuating past complications on new architectures, the 
consensus amongst those writing the ACPI specification and those using
it seems to be to ultimately deprecate the use of _OSI.  I plan to
propose such a change to the ACPI specification in the near future.

In the meantime, these patches rearrange the implementation of _OSI so
that it can be deprecated, or ultimately removed completely, on at least
arm64 platforms.  This is done by simply moving the functions implementing 
_OSI to arch-dependent locations.  For x86, there should be no change
in functionality.  For ia64, while it does duplicate some code from x86,
there is no longer any connection to the ACPI blacklist code that is only
used by x86.  For arm64, any use of the _OSI method generates a warning
that it has been deprecated, and then always returns false; i.e., that
the capability being queried for, whether OS name or functionality, is
not supported.  This is the first six of the patches.

The final patch changes the default value for the _OS_ method for arm64
only.  Since there is no need to pretend to be older versions of Windows,
or any other OS at all, the _OS_ method will return "Linux" on arm64.
One can still use the acpi_os_name kernel parameter if there is a need
to use some other value.

Since we are breaking apart code previously shared, I have tried to make
it so that applying the x86 patches alone will continue to compile, at
the expense of breaking the build on non-x86 platforms.  However, once
all of the patches are applied, we should be able to compile on all three
architectures.  It is best to treat these as one whole.

I have only done simple testing with these patches on arm64 and x86 (AMD
Seattle and a Lenovo t440s ThinkPad, respectively).  Things seem to work
as they should once booted, but this is a very, very small sample of
possible machines.  The ia64 patches cross-compile, but I personally have
no way to test them.

The arm64 patches also rely on having applied Hanjun's patches for ACPI 5.1
on arm64 [0].  The x86 and ia64 parts are not dependent on that patch set,
though, and should be usable independently (i.e., patches 1, 3, 4 and 6).

NB: some of the patches do not pass checkpatch.pl; the failures I saw were
all part of the original code but are only showing up because that code is
changing location, so I have left them as is.  If necessary, they could be
fixed but I was more concerned about the number of changes needed on ia64
and not having any way to test them.


[0] https://lkml.org/lkml/2015/1/14/586


Al Stone (6):
  ia64: ACPI: move kernel acpi files to a directory
  arm64: ACPI: move kernel acpi files to a directory
  x86: ACPI: create arch-dependent version of acpi_osi_handler()
  ia64: ACPI: create arch-dependent version of acpi_osi_handler()
  arm64: ACPI: create arch-dependent version of acpi_osi_handler()
  x86: ia64: arm64: ACPI: move _OSI support functions to arch-dependent
    locations

Hanjun Guo (1):
  ACPI: use Linux as ACPI_OS_NAME for _OS on ARM64

 arch/arm64/Kconfig               |    1 +
 arch/arm64/kernel/Makefile       |    2 +-
 arch/arm64/kernel/acpi.c         |  359 --------------
 arch/arm64/kernel/acpi/Makefile  |    1 +
 arch/arm64/kernel/acpi/acpi.c    |  359 ++++++++++++++
 arch/arm64/kernel/acpi/osi.c     |   26 +
 arch/ia64/kernel/Makefile        |    2 +-
 arch/ia64/kernel/acpi-ext.c      |  104 ----
 arch/ia64/kernel/acpi.c          | 1000 --------------------------------------
 arch/ia64/kernel/acpi/Makefile   |    1 +
 arch/ia64/kernel/acpi/acpi-ext.c |  104 ++++
 arch/ia64/kernel/acpi/acpi.c     | 1000 ++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/acpi/osi.c      |  119 +++++
 arch/x86/kernel/acpi/Makefile    |    2 +-
 arch/x86/kernel/acpi/blacklist.c |  327 +++++++++++++
 arch/x86/kernel/acpi/boot.c      |    5 +-
 arch/x86/kernel/acpi/osi.c       |  255 ++++++++++
 drivers/acpi/Kconfig             |    8 +
 drivers/acpi/Makefile            |    1 -
 drivers/acpi/blacklist.c         |  323 ------------
 drivers/acpi/osl.c               |  217 ---------
 include/acpi/acconfig.h          |    2 +
 include/acpi/platform/aclinux.h  |    4 +
 include/linux/acpi.h             |    4 +-
 24 files changed, 2215 insertions(+), 2011 deletions(-)
 delete mode 100644 arch/arm64/kernel/acpi.c
 create mode 100644 arch/arm64/kernel/acpi/Makefile
 create mode 100644 arch/arm64/kernel/acpi/acpi.c
 create mode 100644 arch/arm64/kernel/acpi/osi.c
 delete mode 100644 arch/ia64/kernel/acpi-ext.c
 delete mode 100644 arch/ia64/kernel/acpi.c
 create mode 100644 arch/ia64/kernel/acpi/Makefile
 create mode 100644 arch/ia64/kernel/acpi/acpi-ext.c
 create mode 100644 arch/ia64/kernel/acpi/acpi.c
 create mode 100644 arch/ia64/kernel/acpi/osi.c
 create mode 100644 arch/x86/kernel/acpi/blacklist.c
 create mode 100644 arch/x86/kernel/acpi/osi.c
 delete mode 100644 drivers/acpi/blacklist.c

-- 
2.1.0

