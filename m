From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 11 Aug 2003 01:17:48 +0000
Subject: [PATCH] Kill `unused variable' warnings in unistd.h (2.6.0-testX)
Message-Id: <marc-linux-ia64-106056471130687@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi David,
   As  discussed on the debian-ia64 list, here's a patch to get rid of
all the _syscallN() macros in asm/unistd.h in favour of direct calls
to kernel functions, plus some hairy inline assembler to do real
system calls for  clone() and execve().  Actually, as neither of these
is performance critical it may have been better just to branch to the
fast system call entry point, and let it do the work.  But this was
simpler.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1123  -> 1.1124 
#	include/asm-ia64/unistd.h	1.30    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/11	peterc@gelato.unsw.edu.au	1.1124
# Kill _syscallX macros that generate lots of warnings, in favour of 
# inline syscalls for clone() and execve(), and direct calling of 
# kernel functions for other system calls.
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/unistd.h b/include/asm-ia64/unistd.h
--- a/include/asm-ia64/unistd.h	Mon Aug 11 11:13:31 2003
+++ b/include/asm-ia64/unistd.h	Mon Aug 11 11:13:31 2003
@@ -257,96 +257,129 @@
 
 extern long __ia64_syscall (long a0, long a1, long a2, long a3, long a4, long nr);
 
-#define _syscall0(type,name)						\
-type									\
-name (void)								\
-{									\
-	register long dummy1 __asm__ ("out0");				\
-	register long dummy2 __asm__ ("out1");				\
-	register long dummy3 __asm__ ("out2");				\
-	register long dummy4 __asm__ ("out3");				\
-	register long dummy5 __asm__ ("out4");				\
-									\
-	return __ia64_syscall(dummy1, dummy2, dummy3, dummy4, dummy5,	\
-			      __NR_##name);				\
-}
-
-#define _syscall1(type,name,type1,arg1)					\
-type									\
-name (type1 arg1)							\
-{									\
-	register long dummy2 __asm__ ("out1");				\
-	register long dummy3 __asm__ ("out2");				\
-	register long dummy4 __asm__ ("out3");				\
-	register long dummy5 __asm__ ("out4");				\
-									\
-	return __ia64_syscall((long) arg1, dummy2, dummy3, dummy4,	\
-			      dummy5, __NR_##name);			\
-}
-
-#define _syscall2(type,name,type1,arg1,type2,arg2)			\
-type									\
-name (type1 arg1, type2 arg2)						\
-{									\
-	register long dummy3 __asm__ ("out2");				\
-	register long dummy4 __asm__ ("out3");				\
-	register long dummy5 __asm__ ("out4");				\
-									\
-	return __ia64_syscall((long) arg1, (long) arg2, dummy3, dummy4,	\
-			      dummy5, __NR_##name);			\
-}
-
-#define _syscall3(type,name,type1,arg1,type2,arg2,type3,arg3)		\
-type									\
-name (type1 arg1, type2 arg2, type3 arg3)				\
-{									\
-	register long dummy4 __asm__ ("out3");				\
-	register long dummy5 __asm__ ("out4");				\
-									\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,	\
-			      dummy4, dummy5, __NR_##name);		\
-}
-
-#define _syscall4(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4)	\
-type										\
-name (type1 arg1, type2 arg2, type3 arg3, type4 arg4)				\
-{										\
-	register long dummy5 __asm__ ("out4");					\
-										\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,		\
-			      (long) arg4, dummy5, __NR_##name);		\
-}
-
-#define _syscall5(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,type5,arg5)	\
-type											\
-name (type1 arg1, type2 arg2, type3 arg3, type4 arg4, type5 arg5)			\
-{											\
-	return __ia64_syscall((long) arg1, (long) arg2, (long) arg3,			\
-			      (long) arg4, (long) arg5, __NR_##name);			\
+#ifdef __KERNEL_SYSCALLS__
+
+#include <linux/string.h>
+#include <linux/signal.h>
+#include <asm/ptrace.h>
+
+extern long sys_open(const char *, int, int);
+static inline long open(const char * name, int mode, int flags)
+{
+	return sys_open(name, mode, flags);
 }
 
-#ifdef __KERNEL_SYSCALLS__
+extern long sys_dup(int);
+static inline long dup(int fd)
+{
+	return sys_dup(fd);
+}
+
+static inline long close(int fd)
+{
+	extern long sys_close(unsigned int);
+	return sys_close(fd);
+}
+
+extern off_t sys_lseek(int, off_t, int);
+static inline off_t lseek(int fd, off_t off, int whence)
+{
+	return sys_lseek(fd, off, whence);
+}
+
+extern long sys_exit(int);
+static inline long _exit(int value)
+{
+	return sys_exit(value);
+}
+
+#define exit(x) _exit(x)
+
+extern long sys_write(int, const char *, size_t);
+static inline long write(int fd, const char * buf, size_t nr)
+{
+	return sys_write(fd, buf, nr);
+}
+
+extern long sys_read(int, char *, size_t);
+static inline long read(int fd, char * buf, size_t nr)
+{
+	return sys_read(fd, buf, nr);
+}
+
+
+extern long sys_setsid(void);
+static inline long setsid(void)
+{
+	return sys_setsid();
+}
 
 struct rusage;
+extern asmlinkage long sys_wait4(pid_t, unsigned int *, int, struct rusage *);
+static inline pid_t waitpid(int pid, int * wait_stat, int flags)
+{
+	return sys_wait4(pid, wait_stat, flags, NULL);
+}
 
-static inline _syscall0(pid_t,setsid)
-static inline _syscall3(int,write,int,fd,const char *,buf,off_t,count)
-static inline _syscall3(int,read,int,fd,char *,buf,off_t,count)
-static inline _syscall3(off_t,lseek,int,fd,off_t,offset,int,count)
-static inline _syscall1(int,dup,int,fd)
-static inline _syscall3(int,execve,const char *,file,char **,argv,char **,envp)
-static inline _syscall3(int,open,const char *,file,int,flag,int,mode)
-static inline _syscall1(int,close,int,fd)
-static inline _syscall4(pid_t,wait4,pid_t,pid,int *,wait_stat,int,options,struct rusage*, rusage)
-static inline _syscall2(pid_t,clone,unsigned long,flags,void*,sp);
+#define __STRINGIFY(x) #x
+#define _STRINGIFY(x) __STRINGIFY(x)
 
-#define __NR__exit __NR_exit
-static inline _syscall1(int,_exit,int,exitcode)
+static inline int execve(const char *filename, char *const av[], char *const ep[]) 
+{
+	register long r8 asm("r8");
+	register long r10 asm("r10");
+	register long r15 asm("r15") = __NR_execve;
+	register long out0 asm("out0") = (long)filename;
+	register long out1 asm("out1") = (long)av;
+	register long out2 asm("out2") = (long)ep;
+
+	__asm __volatile ( "break " _STRINGIFY(__BREAK_SYSCALL) ";;\n\t"
+			  : "=r" (r8), "=r" (r10), "=r" (r15),
+			   "=r" (out0), "=r" (out1), "=r" (out2)
+			   : "2" (r15), "3" (out0), "4" (out1), "5" (out2)
+			   : "memory", "out3", "out4", "out5", 
+			   "out6", "out7",
+			   /* Non-stacked integer registers, minus r8, r10, r15, r13  */
+			   "r2", "r3", "r9", "r11", "r12", "r14", "r16", "r17", "r18",
+			   "r19", "r20", "r21", "r22", "r23", "r24", "r25", "r26", "r27",
+			   "r28", "r29", "r30", "r31",
+			   /* Predicate registers.  */
+			   "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15",
+			   /* Non-rotating fp registers.  */
+			   "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15",
+			   /* Branch registers.  */
+			   "b6", "b7" );
+	return r8;
+}
 
-static inline pid_t
-waitpid (int pid, int *wait_stat, int flags)
+static inline pid_t clone(unsigned long flags, void *sp)
 {
-	return wait4(pid, wait_stat, flags, NULL);
+	register long r8 asm("r8");
+	register long r10 asm("r10");
+	register long r15 asm("r15") = __NR_clone;
+	register long out0 asm("out0") = (long)flags;
+	register long out1 asm("out1") = (long)sp;
+	long retval;
+
+	/* clone clobbers current, hence the "r13" in the clobbers list */
+	__asm __volatile ( "break " _STRINGIFY(__BREAK_SYSCALL) ";;\n\t"
+			  : "=r" (r8), "=r" (r10), "=r" (r15),
+			   "=r" (out0), "=r" (out1)
+			   : "2" (r15), "3" (out0), "4" (out1)
+			   : "memory", "out0", "out1", "out2", "out3", "out4", "out5", "out6", "out7","r13",
+			   /* Non-stacked integer registers, minus r8, r10, r15, r13  */
+			   "r2", "r3", "r9", "r11", "r12", "r14", "r16", "r17", "r18",
+			   "r19", "r20", "r21", "r22", "r23", "r24", "r25", "r26", "r27",
+			   "r28", "r29", "r30", "r31",
+			   /* Predicate registers.  */
+			   "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15",
+			   /* Non-rotating fp registers.  */
+			   "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15",
+			   /* Branch registers.  */
+			   "b6", "b7" );
+	retval = r8;
+	return retval;;
+
 }
 
 #endif /* __KERNEL_SYSCALLS__ */
