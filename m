From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:56:16 +0000
Subject: [Linux-ia64] IA-32 emulation patch: ipc_perm32.patch
Message-Id: <marc-linux-ia64-105590723706000@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In the absence of the patch, this system call fails:

shmctl(shmid, IPC_STAT, &shmid_ds) 

The patch corrects the definition of the ipc_perm32 structure.

	-Arun

=== linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c 1.16 vs edited ==--- 1.16/arch/ia64/ia32/sys_ia32.c	Fri Apr 18 10:55:20 2003
+++ edited/linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c	Thu May 22 17:59:55 2003
@@ -2085,7 +2085,7 @@
 };
 
 struct shmid64_ds32 {
-	struct ipc64_perm shm_perm;
+	struct ipc64_perm32 shm_perm;
 	__kernel_size_t32 shm_segsz;
 	__kernel_time_t32 shm_atime;
 	unsigned int __unused1;


