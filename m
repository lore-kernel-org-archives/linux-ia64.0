From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 24 Sep 2003 06:27:11 +0000
Subject: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106438485815490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 22, 2003 at 04:21:23PM -0700, Richard Henderson wrote:
> On Mon, Sep 22, 2003 at 12:39:18PM -0700, H. J. Lu wrote:
> > Can I get char * from char [300]?
> 
> x+0 would work in this case; I'd guess it'd work for most of the
> cases that syscalls need to handle.
> 

This patch works for me.


H.J.
---
2003-09-22  H.J. Lu  <hongjiu.lu@intel.com>

	* sysdeps/unix/sysv/linux/ia64/sysdep.h (LOAD_ARGS_1): Use
	__typeof ((outX) + 0) instead of long.
	(LOAD_ARGS_2): Likewise.
	(LOAD_ARGS_3): Likewise.
	(LOAD_ARGS_4): Likewise.
	(LOAD_ARGS_5): Likewise.
	(LOAD_ARGS_6): Likewise.

--- sysdeps/unix/sysv/linux/ia64/sysdep.h.inline	2003-08-21 07:05:30.000000000 -0700
+++ sysdeps/unix/sysv/linux/ia64/sysdep.h	2003-09-23 11:04:02.000000000 -0700
@@ -191,23 +191,23 @@
 #define INTERNAL_SYSCALL_ERRNO(val, err)	(val)
 
 #define LOAD_ARGS_0()   do { } while (0)
-#define LOAD_ARGS_1(out0)				\
-  register long _out0 asm ("out0") = (long) (out0);	\
+#define LOAD_ARGS_1(out0)					\
+  register __typeof ((out0) + 0) _out0 asm ("out0") = (out0);	\
   LOAD_ARGS_0 ()
-#define LOAD_ARGS_2(out0, out1)				\
-  register long _out1 asm ("out1") = (long) (out1);	\
+#define LOAD_ARGS_2(out0, out1)					\
+  register __typeof ((out1) + 0) _out1 asm ("out1") = (out1);	\
   LOAD_ARGS_1 (out0)
-#define LOAD_ARGS_3(out0, out1, out2)			\
-  register long _out2 asm ("out2") = (long) (out2);	\
+#define LOAD_ARGS_3(out0, out1, out2)				\
+  register __typeof ((out2) + 0) _out2 asm ("out2") = (out2);	\
   LOAD_ARGS_2 (out0, out1)
-#define LOAD_ARGS_4(out0, out1, out2, out3)		\
-  register long _out3 asm ("out3") = (long) (out3);	\
+#define LOAD_ARGS_4(out0, out1, out2, out3)			\
+  register __typeof ((out3) + 0) _out3 asm ("out3") = (out3);	\
   LOAD_ARGS_3 (out0, out1, out2)
-#define LOAD_ARGS_5(out0, out1, out2, out3, out4)	\
-  register long _out4 asm ("out4") = (long) (out4);	\
+#define LOAD_ARGS_5(out0, out1, out2, out3, out4)		\
+  register __typeof ((out4) + 0) _out4 asm ("out4") = (out4);	\
   LOAD_ARGS_4 (out0, out1, out2, out3)
-#define LOAD_ARGS_6(out0, out1, out2, out3, out4, out5)	\
-  register long _out5 asm ("out5") = (long) (out5);	\
+#define LOAD_ARGS_6(out0, out1, out2, out3, out4, out5)		\
+  register __typeof ((out5) + 0) _out5 asm ("out5") = (out5);	\
   LOAD_ARGS_5 (out0, out1, out2, out3, out4)
 
 #define ASM_OUTARGS_0
