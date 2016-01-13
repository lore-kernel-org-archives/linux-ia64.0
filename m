From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Jan 2016 19:14:40 +0000
Subject: [GIT PULL] fix ia64 build breakage
Message-Id: <5696a220159553f94@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4bff019827164eea63@agluck-desktop.sc.intel.com>
In-Reply-To: <4bff019827164eea63@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 67990608c8b95d2b8ccc29932376ae73d5818727:

  Merge tag 'pm+acpi-4.5-rc1-1' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2016-01-12 20:25:09 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-fixefi

for you to fetch changes up to 0f7f2f0c0fcbe5e2bcba707a628ebaedfe2be4b4:

  efi: include asm/early_ioremap.h not asm/efi.h to get early_memremap (2016-01-13 10:35:14 -0800)

----------------------------------------------------------------
ARM guys broke ia64 build ... but gave me fixes, so it's all good now

----------------------------------------------------------------
Ard Biesheuvel (2):
      ia64: split off early_ioremap() declarations into asm/early_ioremap.h
      efi: include asm/early_ioremap.h not asm/efi.h to get early_memremap

 arch/ia64/include/asm/early_ioremap.h | 10 ++++++++++
 arch/ia64/include/asm/io.h            |  5 +----
 drivers/firmware/efi/efi.c            |  2 +-
 3 files changed, 12 insertions(+), 5 deletions(-)
 create mode 100644 arch/ia64/include/asm/early_ioremap.h
