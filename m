From: akpm@linux-foundation.org
Date: Tue, 06 Mar 2007 10:34:24 +0000
Subject: [patch 4/6] ia64: sync compat getdents
Message-Id: <200703061034.l26AYOm0019349@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Alexandr Andreev <aandreev@openvz.org>

Add VERIFY_WRITE check in the beginning like compat_sys_getdents() (EINVAL vs
EFAULT).

Signed-off-by: Alexandr Andreev <aandreev@openvz.org>
Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/ia32/sys_ia32.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff -puN arch/ia64/ia32/sys_ia32.c~ia64-sync-compat-getdents-on-ia64-and-parisc arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c~ia64-sync-compat-getdents-on-ia64-and-parisc
+++ a/arch/ia64/ia32/sys_ia32.c
@@ -1267,6 +1267,10 @@ sys32_getdents (unsigned int fd, struct 
 	struct getdents32_callback buf;
 	int error;
 
+	error = -EFAULT;
+	if (!access_ok(VERIFY_WRITE, dirent, count))
+		goto out;
+
 	error = -EBADF;
 	file = fget(fd);
 	if (!file)
@@ -1283,10 +1287,10 @@ sys32_getdents (unsigned int fd, struct 
 	error = buf.error;
 	lastdirent = buf.previous;
 	if (lastdirent) {
-		error = -EINVAL;
 		if (put_user(file->f_pos, &lastdirent->d_off))
-			goto out_putf;
-		error = count - buf.count;
+			error = -EFAULT;
+		else
+			error = count - buf.count;
 	}
 
 out_putf:
_
