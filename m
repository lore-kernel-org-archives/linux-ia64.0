From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 27 Jul 2004 20:03:24 +0000
Subject: compat_{f,}statfs64.patch
Message-Id: <4106B50C.8070206@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070705090904070206010809"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070705090904070206010809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Tony/David,

ia32 emulation code needs to use a wrapper for these two system calls. Please apply.

$ cat t.c
#include <asm/statfs.h>

main()
{
        printf("%d\n", sizeof(struct statfs64));
        printf("%d\n", sizeof(struct compat_statfs64));
}
$ ./t
120
84

	-Arun



--------------070705090904070206010809
Content-Type: text/plain;
 name="fstatfs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fstatfs.patch"

ia32 emulation needs wrapper for {f}statfs64 syscall.

Signed-off-by: Gordon Jin <gordon.jin@intel.com>
Signed-off-by: Arun Sharma <arun.sharma@intel.com>

--- linux-2.6.7/arch/ia64/ia32/ia32_entry.S	2004-06-23 17:29:15.000000000 +0800
+++ linux-2.6.7/arch/ia64/ia32/ia32_entry.S.new	2004-07-27 13:22:25.611848994 +0800
@@ -476,8 +476,8 @@
  	data8 compat_clock_gettime /* 265 */
  	data8 compat_clock_getres
  	data8 compat_clock_nanosleep
-	data8 sys_statfs64
-	data8 sys_fstatfs64
+	data8 compat_statfs64
+	data8 compat_fstatfs64
  	data8 sys_tgkill	/* 270 */
  	data8 compat_sys_utimes
  	data8 sys32_fadvise64_64

--------------070705090904070206010809--
