From: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 18 Feb 2008 00:05:21 +0000
Subject: [PATCH] ia64: remove unnecessary nfs includes from
Message-Id: <20080218000521.GA19975@fieldses.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: J. Bruce Fields <bfields@citi.umich.edu>

These nfs includes seem to be completely unused.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 arch/ia64/ia32/sys_ia32.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

On Sun, Feb 17, 2008 at 08:13:14AM -0500, Christoph Hellwig wrote:
> Why does it need to include either of these at all?  There's nothing
> nfs-specific in that file.

Yep.  I tried an ia64 cross-compile with the following applied, and
didn't see any complaints....  Also, looks like:

	arch/parisc/kernel/sys_parisc32.c
	arch/s390/kernel/compat_linux.c
	arch/s390/kernel/compat_linux.h
	arch/sparc64/kernel/sys_sparc32.c
	arch/x86/ia32/sys_ia32.c

have similarly unnecessary nfs includes.

--b.

diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index d025a22..b1bf51f 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -32,13 +32,8 @@
 #include <linux/shm.h>
 #include <linux/slab.h>
 #include <linux/uio.h>
-#include <linux/nfs_fs.h>
+#include <linux/socket.h>
 #include <linux/quota.h>
-#include <linux/sunrpc/svc.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
-#include <linux/nfsd/syscall.h>
 #include <linux/poll.h>
 #include <linux/eventpoll.h>
 #include <linux/personality.h>
-- 
1.5.4.rc2.60.gb2e62

