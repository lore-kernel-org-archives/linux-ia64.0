From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:16 +0000
Subject: [PATCH v3 0/9] Start deprecating _OSI on new architectures
Message-Id: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

The use of the ACPI _OSI method in Linux has a long and sordid history.
Instead of perpetuating past complications on new architectures, the 
consensus amongst those writing the ACPI specification and those using
it seems to be to ultimately deprecate the use of _OSI.  A change request
has been submitted (but not yet decided upon) to modify the ACPI spec
accordingly.

In the meantime, these patches rearrange the implementation of _OSI so
that it can be deprecated, or ultimately removed completely, on at least
arm64 platforms.  This is done by separating out the _OSI implementation
and moving it into a new file.  For x86 and ia64, there is no change in
functionality.  But, this allows us to provide a separate implementation
of _OSI for arm64 that generates a warning that it has been deprecated, 
and always returns false; i.e., that the capability being queried for, 
whether OS name or functionality, is not supported.  Patches 0005
through 0008 provide these changes; the first four patches are solely
cleanup to the file drivers/acpi/osl.c made so that checkpatch will not
complain.

The final patch changes the default value for the _OS_ method for arm64
only.  Since there is no need to pretend to be older versions of Windows,
or any other OS at all, the _OS_ method will return "Linux" on arm64.
One can still use the acpi_os_name kernel parameter if there is a need
to use some other value.

The first seven patches do not depend on arm64 support for ACPI and could
be used independently.  The last two patches make much more sense when used
in conjunction with Hanjun's patches for ACPI 5.1 on arm64 [0].  In fact,
patch 0008 cannot be applied without [0].

These have been through some simple testing on two different x86 laptops,
and all seems well (Lenovo t440s and t430s ThinkPads).  The arm64 code has
been tested on an AMD Seattle system.  Unfortunately, for ia64, all I could
do was cross-compile the code; I have no access to hardware to test on.

NB: the first four patches are solely cleanup to drivers/acpi/osl.c based
on the results from checkpatch and can be treated independently.  However,
the remainder of the patch set assumes this cleanup has been done.  There
are some checkpatch warnings still remaining in osl.c -- specifically about
use of volatiles and one line of 81 characters -- that these patches 
intentionally do not correct as they do not appear to need correcting.

Changes in v3:
  -- add in cleanup to osl.c based on checkpatch output
  -- put arch-specific _OSI implementation in the correct place (arch/*)
  -- modify CONFIG item names and make them so they are not user selectable
  -- get rid of the BLACKLIST config item; it wasn't really needed.

Changes in v2:
  -- significant simplification based on Rafael's comments
  -- ACPI spec change request has now been submitted


[0] https://lkml.org/lkml/2015/2/2/261


Al Stone (9):
  ACPI: fix all errors reported by cleanpatch.pl in osl.c
  ACPI: clear up warnings on use of printk reported by checkpatch.pl
  ACPI: clean up checkpatch warnings for various bits of syntax
  ACPI: clean up checkpatch warnings for items with possible semantic
    value
  ACPI: move acpi_os_handler() so it can be made arch-dependent later
  ACPI: move _OSI support functions to allow arch-dependent
    implementation
  ACPI: enable arch-specific compilation for _OSI and the blacklist
  ACPI: arm64: use an arch-specific ACPI _OSI method and ACPI blacklist
  ACPI: arm64: use "Linux" as ACPI_OS_NAME for _OS on arm64

 arch/arm64/Kconfig                 |   6 +
 arch/arm64/kernel/Makefile         |   2 +-
 arch/arm64/kernel/acpi-blacklist.c |  20 ++
 arch/arm64/kernel/acpi-osi.c       |  25 +++
 drivers/acpi/Kconfig               |   3 +
 drivers/acpi/Makefile              |   5 +
 drivers/acpi/osi.c                 | 245 +++++++++++++++++++++++
 drivers/acpi/osl.c                 | 387 ++++++++-----------------------------
 include/acpi/acconfig.h            |   2 +
 include/acpi/platform/aclinux.h    |   4 +
 include/linux/acpi.h               |  14 +-
 11 files changed, 406 insertions(+), 307 deletions(-)
 create mode 100644 arch/arm64/kernel/acpi-blacklist.c
 create mode 100644 arch/arm64/kernel/acpi-osi.c
 create mode 100644 drivers/acpi/osi.c

-- 
2.1.0

