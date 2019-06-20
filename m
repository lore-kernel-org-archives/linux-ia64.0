From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 20 Jun 2019 17:57:37 +0000
Subject: [PATCH 5.1 70/98] ia64: fix build errors by exporting paddr_to_nid()
Message-Id: <20190620174352.672987898@linuxfoundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190620174349.443386789@linuxfoundation.org>
In-Reply-To: <20190620174349.443386789@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, kbuild test robot <lkp@intel.com>, Randy Dunlap <rdunlap@infradead.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>

[ Upstream commit 9a626c4a6326da4433a0d4d4a8a7d1571caf1ed3 ]

Fix build errors on ia64 when DISCONTIGMEM=y and NUMA=y by
exporting paddr_to_nid().

Fixes these build errors:

ERROR: "paddr_to_nid" [sound/core/snd-pcm.ko] undefined!
ERROR: "paddr_to_nid" [net/sunrpc/sunrpc.ko] undefined!
ERROR: "paddr_to_nid" [fs/cifs/cifs.ko] undefined!
ERROR: "paddr_to_nid" [drivers/video/fbdev/core/fb.ko] undefined!
ERROR: "paddr_to_nid" [drivers/usb/mon/usbmon.ko] undefined!
ERROR: "paddr_to_nid" [drivers/usb/core/usbcore.ko] undefined!
ERROR: "paddr_to_nid" [drivers/md/raid1.ko] undefined!
ERROR: "paddr_to_nid" [drivers/md/dm-mod.ko] undefined!
ERROR: "paddr_to_nid" [drivers/md/dm-crypt.ko] undefined!
ERROR: "paddr_to_nid" [drivers/md/dm-bufio.ko] undefined!
ERROR: "paddr_to_nid" [drivers/ide/ide-core.ko] undefined!
ERROR: "paddr_to_nid" [drivers/ide/ide-cd_mod.ko] undefined!
ERROR: "paddr_to_nid" [drivers/gpu/drm/drm.ko] undefined!
ERROR: "paddr_to_nid" [drivers/char/agp/agpgart.ko] undefined!
ERROR: "paddr_to_nid" [drivers/block/nbd.ko] undefined!
ERROR: "paddr_to_nid" [drivers/block/loop.ko] undefined!
ERROR: "paddr_to_nid" [drivers/block/brd.ko] undefined!
ERROR: "paddr_to_nid" [crypto/ccm.ko] undefined!

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/ia64/mm/numa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index a03803506b0c..5e1015eb6d0d 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -55,6 +55,7 @@ paddr_to_nid(unsigned long paddr)
 
 	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
 }
+EXPORT_SYMBOL(paddr_to_nid);
 
 #if defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
 /*
-- 
2.20.1


