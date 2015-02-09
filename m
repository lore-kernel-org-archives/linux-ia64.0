From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 09 Feb 2015 19:24:47 +0000
Subject: [PATCH] KVM: ia64: drop kvm.h from installed user headers
Message-Id: <1423509887-4822-1-git-send-email-vapier@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The header was deleted, so stop trying to install it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 arch/ia64/include/uapi/asm/Kbuild | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/include/uapi/asm/Kbuild b/arch/ia64/include/uapi/asm/Kbuild
index 1b3f5eb..891002b 100644
--- a/arch/ia64/include/uapi/asm/Kbuild
+++ b/arch/ia64/include/uapi/asm/Kbuild
@@ -18,7 +18,6 @@ header-y += intrinsics.h
 header-y += ioctl.h
 header-y += ioctls.h
 header-y += ipcbuf.h
-header-y += kvm.h
 header-y += kvm_para.h
 header-y += mman.h
 header-y += msgbuf.h
-- 
2.2.1

