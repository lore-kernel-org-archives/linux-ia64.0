From: David Howells <dhowells@redhat.com>
Date: Thu, 18 Oct 2012 16:58:12 +0000
Subject: [PATCH] UAPI: Make arch/ia64/include/asm/kvm_para.h generic
Message-Id: <20121018165812.12560.28578.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Yuanhan Liu <yuanhan.liu@intel.com>, fengguang.wu@intel.com

Make arch/ia64/include/asm/kvm_para.h generic since it's the same as the
asm-generic version.  This deals with the problem when ia64 is compiled with
allmodconfig you get:

In file included from include/uapi/linux/kvm_para.h:26:0,
                 from include/linux/kvm_para.h:4,
                 from kernel/watchdog.c:28:
arch/ia64/include/asm/kvm_para.h:24:28: error: redefinition of 'kvm_arch_para_features'
include/asm-generic/kvm_para.h:16:28: note: previous definition of 'kvm_arch_para_features' was here
arch/ia64/include/asm/kvm_para.h:29:20: error: redefinition of 'kvm_check_and_clear_guest_paused'
include/asm-generic/kvm_para.h:11:20: note: previous definition of 'kvm_check_and_clear_guest_paused' was here

This does not happen for ia64 defconfig.

Reported-by: Yuanhan Liu <yuanhan.liu@intel.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Yuanhan Liu <yuanhan.liu@intel.com>
cc: fengguang.wu@intel.com
---

 arch/ia64/include/asm/Kbuild     |    1 +
 arch/ia64/include/asm/kvm_para.h |   34 ----------------------------------
 2 files changed, 1 insertion(+), 34 deletions(-)
 delete mode 100644 arch/ia64/include/asm/kvm_para.h

diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 4a159da..dd02f09 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,3 +1,4 @@
 
 generic-y += clkdev.h
 generic-y += exec.h
+generic-y += kvm_para.h
diff --git a/arch/ia64/include/asm/kvm_para.h b/arch/ia64/include/asm/kvm_para.h
deleted file mode 100644
index 47c00f9..0000000
--- a/arch/ia64/include/asm/kvm_para.h
+++ /dev/null
@@ -1,34 +0,0 @@
-/*
- * Copyright (C) 2007 Xiantao Zhang <xiantao.zhang@intel.com>
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
- * Place - Suite 330, Boston, MA 02111-1307 USA.
- *
- */
-#ifndef __IA64_KVM_PARA_H
-#define __IA64_KVM_PARA_H
-
-#include <uapi/asm/kvm_para.h>
-
-
-static inline unsigned int kvm_arch_para_features(void)
-{
-	return 0;
-}
-
-static inline bool kvm_check_and_clear_guest_paused(void)
-{
-	return false;
-}
-
-#endif

