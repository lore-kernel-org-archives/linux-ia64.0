From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 00:49:59 +0000
Subject: [Linux-ia64] strace fix
Message-Id: <marc-linux-ia64-105590693005962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recently I noticed that strace reports bogus syscall return values
after any execve() system call.  This was quite annoying and it turns
out to be due to the fact that strace was falling out of sync with the
kernel due to an extra SIGTRAP that is being sent from the kernel's
ELF loader.  The patch below fixes this problem.

	--david

--- defs.h.~1.17.~	Sun Sep  3 16:57:48 2000
+++ defs.h	Mon Jul 30 17:44:56 2001
@@ -274,7 +274,9 @@
 #define TCB_FOLLOWFORK	00400	/* Process should have forks followed */
 #define TCB_REPRINT	01000	/* We should reprint this syscall on exit */
 #ifdef LINUX
-#if defined(ALPHA) || defined(SPARC) || defined(POWERPC)
+#if defined(ALPHA) || defined(SPARC) || defined(POWERPC) || defined(IA64)
+  /* When execve'ing an ELF binary, the kernel sends an extra SIGTRAP
+     which we need to ignore.  */
 #define TCB_WAITEXECVE	02000	/* ignore SIGTRAP after exceve */
 #endif /* ALPHA */
 #endif /* LINUX */
--- process.c.~1.26.2.2.~	Thu May 17 01:39:53 2001
+++ process.c	Mon Jul 30 17:40:37 2001
@@ -1162,7 +1162,7 @@
 		}
 	}
 #ifdef LINUX
-#if defined(ALPHA) || defined(SPARC) || defined(POWERPC)
+#if defined(ALPHA) || defined(SPARC) || defined(POWERPC) || defined(IA64)
 	tcp->flags |= TCB_WAITEXECVE;
 #endif /* ALPHA || SPARC || POWERPC */
 #endif /* LINUX */
--- syscall.c.~1.25.2.3.~	Tue Mar  6 17:13:25 2001
+++ syscall.c	Mon Jul 30 17:42:21 2001
@@ -691,6 +691,10 @@
 			if (upeek(pid, PT_R8, &scno) < 0)
 				return -1;
 		} else {
+			if ((tcp->flags & TCB_WAITEXECVE)) {
+				tcp->flags &= ~TCB_WAITEXECVE;
+				return 0;
+			}
 			if (upeek (pid, PT_R15, &scno) < 0)
 				return -1;
 		}

