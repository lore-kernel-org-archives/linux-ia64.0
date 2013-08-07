From: Leif Lindholm <leif.lindholm@linaro.org>
Date: Wed, 07 Aug 2013 18:54:15 +0000
Subject: [PATCH v3 0/5] Make commonly useful UEFI functions common
Message-Id: <1375901660-23541-1-git-send-email-leif.lindholm@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, matt.fleming@intel.com, tony.luck@gmail.com, grant.likely@secretlab.ca, Leif Lindholm <leif.lindholm@linaro.org>

This set breaks out some common code from x86/ia64 EFI support
code and puts it into drivers/firmware/efi.

First it takes the definition of the global "efi" data structure
and moves it into global efi.c. Then it implements a common version
of efi_config_init().

Secondly it breaks the efi_lookup_mapped_addr() function out of x86
and places it in global efi.c, for shared use with future ARM
patches.

IA64 code compile tested only.

Leif Lindholm (5):
  ia64: add early_memremap() alias for early_ioremap()
  efi: provide a generic efi_config_init()
  efi: x86: use common code for (U)EFI configuration scanning
  efi: ia64: use common code for (U)EFI configuration scanning
  efi: x86: make efi_lookup_mapped_addr() a common function

 arch/ia64/include/asm/io.h  |    1 +
 arch/ia64/kernel/efi.c      |   54 ++++-------------
 arch/x86/platform/efi/efi.c |  126 ++++----------------------------------
 drivers/firmware/efi/efi.c  |  140 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/efi.h         |    8 +++
 5 files changed, 170 insertions(+), 159 deletions(-)

-- 
1.7.10.4

