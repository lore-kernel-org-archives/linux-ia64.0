From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 21 Jul 2015 16:35:42 +0000
Subject: [PATCH -next] ia64: Increase NR_syscalls to match size of syscall table
Message-Id: <1437496542-7352-1-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>

Commit 05aa30a22eff ("mm: mlock: add new mlock, munlock, and munlockall
system calls") added new system calls, but did not increase the size of the
syscall table for the ia64 architecture, resulting in the following build
error.

arch/ia64/kernel/entry.S: Assembler messages:
arch/ia64/kernel/entry.S:1775: Error: attempt to move .org backwards

Fixes: 05aa30a22eff ("mm: mlock: add new mlock, munlock, and munlockall
	system calls")
Cc: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/ia64/include/asm/unistd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 95c39b95e97e..db73390568c8 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -11,7 +11,7 @@
 
 
 
-#define NR_syscalls			319 /* length of syscall table */
+#define NR_syscalls			322 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
-- 
2.1.0

