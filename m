From: Gary Hade <garyhade@us.ibm.com>
Date: Tue, 08 Jul 2003 22:18:29 +0000
Subject: Re: ia64 sys32_sysinfo problem/fix
Message-Id: <marc-linux-ia64-105770270916830@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could you send a patch, please?  Arun Sharma is the ia32 subsystem
> maintainer, so it would require his approval anyhow...  (I assume it's
> OK, given that it has made it into 2.4.)

David/Arun,
The below patch applies cleanly to the ia64-030619 patched 2.5.72.

Thanks,
Gary

--
Gary Hade
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--- linux-2.5.72/arch/ia64/ia32/sys_ia32.c.orig	2003-07-08 13:54:36.000000000 -0700
+++ linux-2.5.72/arch/ia64/ia32/sys_ia32.c	2003-07-08 13:57:44.000000000 -0700
@@ -2542,13 +2542,31 @@
 sys32_sysinfo (struct sysinfo32 *info)
 {
 	extern asmlinkage long sys_sysinfo (struct sysinfo *);
-	mm_segment_t old_fs = get_fs();
 	struct sysinfo s;
 	long ret, err;
+	int bitcount = 0;
+	mm_segment_t old_fs = get_fs();
 
 	set_fs(KERNEL_DS);
 	ret = sys_sysinfo(&s);
 	set_fs(old_fs);
+	/* Check to see if any memory value is too large for 32-bit and
+	 * scale down if needed.
+	 */
+	if ((s.totalram >> 32) || (s.totalswap >> 32)) {
+		while (s.mem_unit < PAGE_SIZE) {
+			s.mem_unit <<= 1;
+			bitcount++;
+		}
+		s.totalram >>= bitcount;
+		s.freeram >>= bitcount;
+		s.sharedram >>= bitcount;
+		s.bufferram >>= bitcount;
+		s.totalswap >>= bitcount;
+		s.freeswap >>= bitcount;
+		s.totalhigh >>= bitcount;
+		s.freehigh >>= bitcount;
+	}
 
 	if (!access_ok(VERIFY_WRITE, info, sizeof(*info)))
 		return -EFAULT;
