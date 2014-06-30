From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Mon, 30 Jun 2014 17:52:54 +0000
Subject: [PATCH v7 00/10] xen: Add EFI support
Message-Id: <1404150784-27921-1-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: andrew.cooper3@citrix.com, boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, mjg59@srcf.ucam.org, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

Hey,

This patch series adds EFI support for Xen dom0 guests.
It is based on Jan Beulich and Tang Liang work. I was
trying to take into account all previous comments,
however, if I missed something sorry for that.

Daniel

 arch/ia64/include/asm/io.h       |    1 +
 arch/x86/kernel/setup.c          |    4 +-
 arch/x86/platform/efi/efi.c      |  106 ++++++++++--------------
 arch/x86/xen/enlighten.c         |   15 ++++
 drivers/firmware/efi/efi.c       |   25 +++---
 drivers/xen/Kconfig              |    4 +
 drivers/xen/Makefile             |    3 +
 drivers/xen/efi.c                |  368 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/efi.h              |    4 +-
 include/xen/interface/platform.h |  123 ++++++++++++++++++++++++++++
 include/xen/xen-ops.h            |   11 +++
 11 files changed, 587 insertions(+), 77 deletions(-)

Daniel Kiper (10):
      arch/ia64: Define early_memunmap()
      efi: Use early_mem*() instead of early_io*()
      arch/x86: Do not access EFI memory map if it is not available
      efi: Introduce EFI_PARAVIRT flag
      arch/x86: Remove redundant set_bit(EFI_SYSTEM_TABLES) call
      arch/x86: Remove redundant set_bit(EFI_MEMMAP) call
      xen: Define EFI related stuff
      xen: Put EFI machinery in place
      arch/x86: Replace plain strings with constants
      arch/x86: Remove efi_set_rtc_mmss()

