From: Joe Perches <joe@perches.com>
Date: Wed, 25 May 2011 17:02:37 +0000
Subject: [PATCH 0/4] printk: cleanups of direct includes
Message-Id: <cover.1306342673.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BANLkTimo30L7feKr9_Ec=fMoe1erw8Rnag@mail.gmail.com>
In-Reply-To: <BANLkTimo30L7feKr9_Ec=fMoe1erw8Rnag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>, kvm-ia64@vger.kernel.org, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, oprofile-list@lists.sf.net
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-wireless@vger.kernel.org, devel@driverdev.osuosl.org

printk.h is a subfile of kernel.h, do not allow it to
be included directly.

Joe Perches (4):
  treewide: Remove direct includes of printk.h
  staging: Remove direct includes of printk.h
  printk: Don't allow direct inclusion
  treewide: Remove asmlinkage from printk

 arch/arm/kernel/early_printk.c                |    2 +-
 arch/ia64/kvm/vmm.c                           |    2 +-
 arch/x86/kernel/early_printk.c                |    2 +-
 drivers/staging/brcm80211/brcmfmac/dhd_sdio.c |    1 -
 drivers/staging/brcm80211/util/bcmutils.c     |    1 -
 drivers/staging/usbip/usbip_common.h          |    2 +-
 fs/ext4/inode.c                               |    1 -
 include/linux/oprofile.h                      |    2 +-
 include/linux/printk.h                        |   10 +++++++---
 kernel/printk.c                               |    6 +++---
 kernel/sysctl.c                               |    3 +--
 11 files changed, 16 insertions(+), 16 deletions(-)

-- 
1.7.4.rc3

