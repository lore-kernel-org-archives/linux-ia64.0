From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 11 Aug 2003 22:50:32 +0000
Subject: [PATCH] Kill warnings in sys_ia32.c (2.6.0)
Message-Id: <marc-linux-ia64-106064228203795@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch kills compilation warnings in sys_ia32.c. 


=== arch/ia64/ia32/sys_ia32.c 1.70 vs edited ==--- 1.70/arch/ia64/ia32/sys_ia32.c	Fri Aug  8 10:00:00 2003
+++ edited/arch/ia64/ia32/sys_ia32.c	Mon Aug 11 14:38:49 2003
@@ -1374,7 +1374,7 @@
 			break;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_msgctl(first, second, &m64);
+		err = sys_msgctl(first, second, (struct msqid_ds *)&m64);
 		set_fs(old_fs);
 		break;
 
@@ -1382,7 +1382,7 @@
 	      case MSG_STAT:
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_msgctl(first, second, (void *) &m64);
+		err = sys_msgctl(first, second, (struct msqid_ds *)&m64);
 		set_fs(old_fs);
 
 		if (version = IPC_64) {
@@ -1518,7 +1518,7 @@
 			break;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_shmctl(first, second, &s64);
+		err = sys_shmctl(first, second, (struct shmid_ds *)&s64);
 		set_fs(old_fs);
 		break;
 
@@ -1526,7 +1526,7 @@
 	      case SHM_STAT:
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_shmctl(first, second, (void *) &s64);
+		err = sys_shmctl(first, second, (struct shmid_ds *)&s64);
 		set_fs(old_fs);
 		if (err < 0)
 			break;
@@ -1693,6 +1693,10 @@
 	}
 	return i;
 }
+
+asmlinkage long
+compat_sys_wait4(compat_pid_t pid, compat_uint_t * stat_addr, int options,
+		 struct compat_rusage *ru);
 
 asmlinkage long
 sys32_waitpid (int pid, unsigned int *stat_addr, int options)
