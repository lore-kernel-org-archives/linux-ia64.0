From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:35:20 +0000
Subject: Re: [Linux-ia64] IA-32 emulation patch: msgctl.patch
Message-Id: <marc-linux-ia64-105590723705995@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705994@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705994@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun Sharma <arun.sharma@intel.com> writes:

> IA-32 programs executing:
> 
> msgctl(id, IPC_SET, &buf)
> 
> currently fail with EPERM due to this bug. 
> 

My mailer ate the patch.

        -Arun

diff -burN linux/arch/ia64/ia32/sys_ia32.c linux-changed/arch/ia64/ia32/sys_ia32.c
--- linux/arch/ia64/ia32/sys_ia32.c	2003-04-09 19:22:09.000000000 +0800
+++ linux-changed/arch/ia64/ia32/sys_ia32.c	2003-04-09 19:19:57.000000000 +0800
@@ -2314,21 +2314,21 @@
 
 	      case IPC_SET:
 		if (version = IPC_64) {
-			err = get_user(m.msg_perm.uid, &up64->msg_perm.uid);
-			err |= get_user(m.msg_perm.gid, &up64->msg_perm.gid);
-			err |= get_user(m.msg_perm.mode, &up64->msg_perm.mode);
-			err |= get_user(m.msg_qbytes, &up64->msg_qbytes);
+			err = get_user(m64.msg_perm.uid, &up64->msg_perm.uid);
+			err |= get_user(m64.msg_perm.gid, &up64->msg_perm.gid);
+			err |= get_user(m64.msg_perm.mode, &up64->msg_perm.mode);
+			err |= get_user(m64.msg_qbytes, &up64->msg_qbytes);
 		} else {
-			err = get_user(m.msg_perm.uid, &up32->msg_perm.uid);
-			err |= get_user(m.msg_perm.gid, &up32->msg_perm.gid);
-			err |= get_user(m.msg_perm.mode, &up32->msg_perm.mode);
-			err |= get_user(m.msg_qbytes, &up32->msg_qbytes);
+			err = get_user(m64.msg_perm.uid, &up32->msg_perm.uid);
+			err |= get_user(m64.msg_perm.gid, &up32->msg_perm.gid);
+			err |= get_user(m64.msg_perm.mode, &up32->msg_perm.mode);
+			err |= get_user(m64.msg_qbytes, &up32->msg_qbytes);
 		}
 		if (err)
 			break;
 		old_fs = get_fs();
 		set_fs(KERNEL_DS);
-		err = sys_msgctl(first, second, &m);
+		err = sys_msgctl(first, second, &m64);
 		set_fs(old_fs);
 		break;"


