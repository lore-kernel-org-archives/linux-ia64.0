From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:46:35 +0000
Subject: [Linux-ia64] IA-32 emulation patch: shmctl.patch
Message-Id: <marc-linux-ia64-105590723705997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This one is similar to msgctl. We should be calling sys_shmctl with
struct shmid64_ds. 

In the absence of this patch:

shmctl(shmid, IPC_SET, &shmid_ds)

will fail.

	-Arun

diff -burN linux/arch/ia64/ia32/sys_ia32.c linux-changed/arch/ia64/ia32/sys_ia32.c
--- linux/arch/ia64/ia32/sys_ia32.c	2003-04-17 15:43:11.000000000 +0800
+++ linux-changed/arch/ia64/ia32/sys_ia32.c	2003-04-18 11:40:46.000000000 +0800
@@ -2408,7 +2408,7 @@
 shmctl32 (int first, int second, void *uptr)
 {
 	int err = -EFAULT, err2;
-	struct shmid_ds s;
+
 	struct shmid64_ds s64;
 	struct shmid_ds32 *up32 = (struct shmid_ds32 *)uptr;
 	struct shmid64_ds32 *up64 = (struct shmid64_ds32 *)uptr;
@@ -2460,19 +2460,19 @@
 
 	      case IPC_SET:
 		if (version = IPC_64) {
-			err = get_user(s.shm_perm.uid, &up64->shm_perm.uid);
-			err |= get_user(s.shm_perm.gid, &up64->shm_perm.gid);
-			err |= get_user(s.shm_perm.mode, &up64->shm_perm.mode);
+			err = get_user(s64.shm_perm.uid, &up64->shm_perm.uid);
+			err |= get_user(s64.shm_perm.gid, &up64->shm_perm.gid);
+			err |= get_user(s64.shm_perm.mode, &up64->shm_perm.mode);
 		} else {
-			err = get_user(s.shm_perm.uid, &up32->shm_perm.uid);
-			err |= get_user(s.shm_perm.gid, &up32->shm_perm.gid);
-			err |= get_user(s.shm_perm.mode, &up32->shm_perm.mode);
+			err = get_user(s64.shm_perm.uid, &up32->shm_perm.uid);
+			err |= get_user(s64.shm_perm.gid, &up32->shm_perm.gid);
+			err |= get_user(s64.shm_perm.mode, &up32->shm_perm.mode);
 		}
 		if (err)
 			break;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_shmctl(first, second, &s);
+		err = sys_shmctl(first, second, &s64);
 		set_fs(old_fs);
 		break;"


