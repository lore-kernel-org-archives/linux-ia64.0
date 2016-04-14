From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 14 Apr 2016 20:00:02 +0000
Subject: [PATCH 1/3] kexec: don't invoke OOM-killer for control page allocation
Message-Id: <E1aqnQo-0001Tu-Ch@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160414195938.GV19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Biederman <ebiederm@xmission.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, kexec@lists.infradead.org

If we are unable to find a suitable page when allocating the control
page, do not invoke the OOM-killer: killing processes probably isn't
going to help.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 include/linux/kexec.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 2cc643c6e870..1b32ab587f66 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -41,7 +41,7 @@
 #endif
 
 #ifndef KEXEC_CONTROL_MEMORY_GFP
-#define KEXEC_CONTROL_MEMORY_GFP GFP_KERNEL
+#define KEXEC_CONTROL_MEMORY_GFP (GFP_KERNEL | __GFP_NORETRY)
 #endif
 
 #ifndef KEXEC_CONTROL_PAGE_SIZE
-- 
2.1.0

