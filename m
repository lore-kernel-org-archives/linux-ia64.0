From: Daniel Kiper <daniel.kiper@oracle.com>
Date: Tue, 25 Mar 2014 20:57:51 +0000
Subject: [PATCH v3 0/5] xen: Add EFI support
Message-Id: <1395781076-12000-1-git-send-email-daniel.kiper@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-efi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com, eshelton@pobox.com, fenghua.yu@intel.com, hpa@zytor.com, ian.campbell@citrix.com, jbeulich@suse.com, jeremy@goop.org, konrad.wilk@oracle.com, matt.fleming@intel.com, mingo@redhat.com, stefano.stabellini@eu.citrix.com, tglx@linutronix.de, tony.luck@intel.com

Hey,

This patch series adds EFI support for Xen dom0 guests.
It is based on Jan Beulich and Tang Liang work. I was
trying to take into account all previous comments,
however, if I missed something sorry for that.

Additionally, I attempted to leave all credits as is and
put SOB in relevant places. If I made any mistake drop me
a line and I will fix it in next version.

Feel free to play with it. I am looking forward for your comments.

Daniel

 arch/ia64/kernel/efi.c           |   30 ++++--
 arch/x86/kernel/setup.c          |    2 +-
 arch/x86/platform/efi/efi.c      |   20 ++--
 arch/x86/xen/enlighten.c         |   10 ++
 drivers/firmware/efi/efi.c       |   26 ++++++
 drivers/xen/Kconfig              |    3 +
 drivers/xen/Makefile             |    1 +
 drivers/xen/efi.c                |  425 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/efi.h              |   10 ++
 include/xen/interface/platform.h |  123 +++++++++++++++++++++++-
 10 files changed, 633 insertions(+), 17 deletions(-)

Daniel Kiper (5):
      efi: Add efi_init_ops variable
      efi: Export arch_tables variable
      x86: Call efi_memblock_x86_reserve_range() on native EFI platform only
      xen: Define EFI related stuff
      xen: Put EFI machinery in place

