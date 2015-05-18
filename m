From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 18 May 2015 21:27:19 +0000
Subject: [PATCH] ia64: Return -ENOMEM in ia64_mmap_check() error case
Message-Id: <1431984439-15008-1-git-send-email-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

The value -ENOMEM is the expected return code for mmap when
the address range verification failes on a MAP_FIXED
request, as stated in the specification:

	[ENOMEM]
	    MAP_FIXED was specified, and the range
	    [addr,addr+len) exceeds that allowed for the
	    address space of a process;

The ia64_mmap_check() function is part of that verification
and should return -ENOMEM too.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/ia64/kernel/sys_ia64.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index 41e33f8..e927023 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -124,7 +124,7 @@ int ia64_mmap_check(unsigned long addr, unsigned long len,
 	 */
 	roff = REGION_OFFSET(addr);
 	if ((len > RGN_MAP_LIMIT) || (roff > (RGN_MAP_LIMIT - len)))
-		return -EINVAL;
+		return -ENOMEM;
 	return 0;
 }
 
-- 
1.8.4.5

