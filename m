From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 07 Jan 2003 01:39:05 +0000
Subject: [Linux-ia64] strace improvement patch
Message-Id: <marc-linux-ia64-105590709805640@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Below is a patch to make "strace -f" work (again) for clone()/clone2()
system calls.  Most of the patch is from Roland's (?) patch shipped
with the strace-4.8-8 RPM (strace-4.4-clone-fixes.patch).  The only
changes I made are:

 * defs.h: declare pid2tcb() to avoid pointer-truncation on 64-bit platforms.
 * process.c: define internal_clone() if either SYS_clone or SYS_clone2
	is defined.
 * util.c (arg_setup) [IA64]: Make it work for syscall-stubs that have
	a non-empty local register partition.
   (set_arg0) [IA64]: Fix it so it actually works.
   (set_arg1) [IA64]: Ditto.
   (setbpt): Treat SYS_clone2 like SYS_clone.

Also, I'd recommend to use gcc-3.2 for compiling strace.  I
encountered some strange bugs with gcc-2.96, though I did not try to
track them down.  With gcc-3.2, those bugs went away and strace now
seems to work quite nicely (once again, that is).  Oh, I only tested
on 2.5.xx, though I think it should work fine on 2.4.xx as well.

Is there any reason not to integrate Roland's patch into strace?
IMHO, the new approach of using CLONE_PTRACE to trace clone()/fork()
is infinitely better than the old code-patching approach.

	--david

Index: defs.h
=================================RCS file: /cvsroot/strace/strace/defs.h,v
retrieving revision 1.34
diff -u -r1.34 defs.h
--- defs.h	30 Dec 2002 00:25:36 -0000	1.34
+++ defs.h	7 Jan 2003 01:23:12 -0000
@@ -371,6 +371,7 @@
 extern int set_personality P((int personality));
 extern char *xlookup P((struct xlat *, int));
 extern struct tcb *alloctcb P((int));
+extern struct tcb *pid2tcb P((int pid));
 extern void droptcb P((struct tcb *));
 
 extern void set_sortby P((char *));
Index: process.c
=================================RCS file: /cvsroot/strace/strace/process.c,v
retrieving revision 1.44
diff -u -r1.44 process.c
--- process.c	22 Dec 2002 03:34:36 -0000	1.44
+++ process.c	7 Jan 2003 01:23:12 -0000
@@ -726,7 +726,7 @@
 	return 0;
 }
 
-#ifdef SYS_clone
+#if defined(SYS_clone) || defined(SYS_clone2)
 int
 internal_clone(tcp)
 struct tcb *tcp;
@@ -753,6 +753,26 @@
 		}
 
 		pid = tcp->u_rval;
+#ifdef LINUX
+		tcpchild = pid2tcb(pid);
+		if (tcpchild != NULL) {
+		  /* The child already reported its startup trap before
+		     the parent reported its syscall return.  */
+		  if ((tcpchild->flags
+		       & (TCB_STARTUP|TCB_ATTACHED|TCB_SUSPENDED))
+		      != (TCB_STARTUP|TCB_ATTACHED|TCB_SUSPENDED))
+		    {
+		      fprintf(stderr,
+			      "[preattached child %d of %d in weird state!]\n",
+			      pid, tcp->pid);
+		    }
+		  else
+		    {
+		      tcpchild->flags |= TCB_SUSPENDED;
+		    }
+		}
+		else
+#endif
 		if ((tcpchild = alloctcb(pid)) = NULL) {
 			if (bpt)
 				clearbpt(tcp);
@@ -761,6 +781,7 @@
 			return 0;
 		}
 
+#ifndef LINUX			/* see new setbpt */
 		/* Attach to the new child */
 		if (ptrace(PTRACE_ATTACH, pid, (char *) 1, 0) < 0) {
 			if (bpt)
@@ -770,22 +791,42 @@
 			droptcb(tcpchild);
 			return 0;
 		}
+#endif
 
 		if (bpt)
 			clearbpt(tcp);
 
 		tcpchild->flags |= TCB_ATTACHED;
+		/* Child has BPT too, must be removed on first occasion */
 		if (bpt) {
 			tcpchild->flags |= TCB_BPTSET;
 			tcpchild->baddr = tcp->baddr;
 			memcpy(tcpchild->inst, tcp->inst,
 				sizeof tcpchild->inst);
 		}
-		newoutf(tcpchild);
 		tcpchild->parent = tcp;
 		tcp->nchildren++;
-		if (!qflag)
-			fprintf(stderr, "Process %d attached\n", pid);
+		if (tcpchild->flags & TCB_SUSPENDED)
+		  {
+		    if (bpt)
+		      clearbpt(tcpchild);
+
+		    tcpchild->flags &= ~(TCB_SUSPENDED|TCB_STARTUP);
+		    if (ptrace(PTRACE_SYSCALL, pid, (char *) 1, 0) < 0) {
+		      perror("resume: ptrace(PTRACE_SYSCALL, ...)");
+		      return -1;
+		    }
+
+		    if (!qflag)
+		      fprintf(stderr, "Process %u resumed (parent %d ready)\n",
+			      pid, tcp->pid);
+		  }
+		else
+		  {
+		    newoutf(tcpchild);
+		    if (!qflag)
+		      fprintf(stderr, "Process %d attached\n", pid);
+		  }
 	}
 	return 0;
 }
@@ -807,6 +848,10 @@
 			dont_follow = 1;
 	}
 #endif
+#ifdef LINUX
+	return internal_clone(tcp);
+#else
+
 	if (entering(tcp)) {
 		if (!followfork || dont_follow)
 			return 0;
@@ -904,6 +949,7 @@
 			fprintf(stderr, "Process %d attached\n", pid);
 	}
 	return 0;
+#endif
 }
 
 #endif /* !USE_PROCFS */
Index: strace.c
=================================RCS file: /cvsroot/strace/strace/strace.c,v
retrieving revision 1.38
diff -u -r1.38 strace.c
--- strace.c	30 Dec 2002 09:33:22 -0000	1.38
+++ strace.c	7 Jan 2003 01:23:12 -0000
@@ -84,7 +84,6 @@
 extern const char version[];
 extern char **environ;
 
-static struct tcb *pid2tcb P((int pid));
 static int trace P((void));
 static void cleanup P((void));
 static void interrupt P((int sig));
@@ -932,7 +931,7 @@
 
 #endif /* USE_PROCFS */
 
-static struct tcb *
+struct tcb *
 pid2tcb(pid)
 int pid;
 {
@@ -1126,6 +1125,15 @@
 			}
 		}
 	}
+
+	/* Linux kernel leaves him in SIGSTOP'd state after detach.  */
+	if (waitpid (tcp->pid, &status, WUNTRACED) < 0) {
+	  if (errno != ECHILD) {
+	    perror("detach: waiting");
+	  }
+	} else {
+	  kill(tcp->pid, SIGCONT);
+	}
 #endif /* LINUX */
 
 #if defined(SUNOS4)
@@ -1780,25 +1788,38 @@
 
 		/* Look up `pid' in our table. */
 		if ((tcp = pid2tcb(pid)) = NULL) {
-#if 0 /* XXX davidm */ /* WTA: disabled again */
-			struct tcb *tcpchild;
-
-			if ((tcpchild = alloctcb(pid)) = NULL) {
+#ifdef LINUX
+		  if (followfork)
+		    {
+		      /* Enabled again 2002-08-28 by <roland@redhat.com>.
+
+		         This is needed to go with the CLONE_PTRACE changes
+			 in process.c/util.c: we might see the child's
+			 initial trap before we see the parent return from
+			 the clone syscall.  Leave the child suspended until
+			 the parent returns from its system call.  Only then
+			 will we have the association of parent and child
+			 so that we know how to do clearbpt in the child.  */
+		      if ((tcp = alloctcb(pid)) = NULL) {
 				fprintf(stderr, " [tcb table full]\n");
 				kill(pid, SIGKILL); /* XXX */
 				return 0;
 			}
-			tcpchild->flags |= TCB_ATTACHED;
-			newoutf(tcpchild);
-			tcp->nchildren++;
+		      tcp->flags |= TCB_ATTACHED | TCB_SUSPENDED;
+		      newoutf(tcp);
 			if (!qflag)
-				fprintf(stderr, "Process %d attached\n", pid);
-#else
+			fprintf(stderr,
+				"Process %d attached (waiting for parent)\n",
+				pid);
+		    }
+		  else
+#endif
+		    {
 			fprintf(stderr, "unknown pid: %u\n", pid);
 			if (WIFSTOPPED(status))
 				ptrace(PTRACE_CONT, pid, (char *) 1, 0);
 			exit(1);
-#endif
+		    }
 		}
 		/* set current output file */
 		outf = tcp->outf;
Index: syscall.c
=================================RCS file: /cvsroot/strace/strace/syscall.c,v
retrieving revision 1.43
diff -u -r1.43 syscall.c
--- syscall.c	30 Dec 2002 10:23:00 -0000	1.43
+++ syscall.c	7 Jan 2003 01:23:12 -0000
@@ -896,16 +896,16 @@
 			if (upeek (pid, PT_R15, &scno) < 0)
 				return -1;
 		}
+		if (tcp->flags & TCB_WAITEXECVE) {
+			tcp->flags &= ~TCB_WAITEXECVE;
+			return 0;
+		}
 	} else {
 		/* syscall in progress */
 		if (upeek (pid, PT_R8, &r8) < 0)
 			return -1;
 		if (upeek (pid, PT_R10, &r10) < 0)
 			return -1;
-	}
-	if (tcp->flags & TCB_WAITEXECVE) {
-		tcp->flags &= ~TCB_WAITEXECVE;
-		return 0;
 	}
 
 #elif defined (ARM)
Index: util.c
=================================RCS file: /cvsroot/strace/strace/util.c,v
retrieving revision 1.31
diff -u -r1.31 util.c
--- util.c	16 Dec 2002 20:40:54 -0000	1.31
+++ util.c	7 Jan 2003 01:23:13 -0000
@@ -52,7 +52,8 @@
 #endif
 
 #if defined(LINUX) && defined(IA64)
-#include <asm/ptrace_offsets.h>
+# include <asm/ptrace_offsets.h>
+# include <asm/rse.h>
 #endif
 
 #ifdef HAVE_SYS_REG_H
@@ -1107,6 +1108,193 @@
 
 #ifndef USE_PROCFS
 
+#if defined LINUX
+
+#include <sys/syscall.h>
+#ifndef CLONE_PTRACE
+# define CLONE_PTRACE    0x00002000
+#endif
+
+#ifdef IA64
+
+typedef unsigned long *arg_setup_state;
+
+static int
+arg_setup(struct tcb *tcp, arg_setup_state *state)
+{
+  unsigned long *bsp, cfm, i, sof, sol;
+
+  if (upeek(tcp->pid, PT_AR_BSP, (long *) &bsp) < 0)
+    return -1;
+  if (upeek(tcp->pid, PT_CFM, (long *) &cfm) < 0)
+    return -1;
+
+  sof = (cfm >> 0) & 0x7f;
+  sol = (cfm >> 7) & 0x7f;
+  bsp = ia64_rse_skip_regs(bsp, -sof + sol);
+
+  *state = bsp;
+  return 0;
+}
+
+# define arg_finish_change(tcp, state)	0
+
+static int
+get_arg0 (struct tcb *tcp, arg_setup_state *state, long *valp)
+{
+  return umoven (tcp, (unsigned long) ia64_rse_skip_regs(*state, 0),
+		 sizeof(long), (void *) valp);
+}
+
+static int
+get_arg1 (struct tcb *tcp, arg_setup_state *state, long *valp)
+{
+  return umoven (tcp, (unsigned long) ia64_rse_skip_regs(*state, 1),
+		 sizeof(long), (void *) valp);
+}
+
+static int
+set_arg0 (struct tcb *tcp, arg_setup_state *state, long val)
+{
+  unsigned long *ap;
+  ap = ia64_rse_skip_regs(*state, 0);
+  errno = 0;
+  ptrace(PTRACE_POKEDATA, tcp->pid, (void *) ap, val);
+  return errno ? -1 : 0;
+}
+
+static int
+set_arg1 (struct tcb *tcp, arg_setup_state *state, long val)
+{
+  unsigned long *ap;
+  ap = ia64_rse_skip_regs(*state, 1);
+  errno = 0;
+  ptrace(PTRACE_POKEDATA, tcp->pid, (void *) ap, val);
+  return errno ? -1 : 0;
+}
+
+#elif defined (SPARC)
+
+typedef struct regs arg_setup_state;
+
+# define arg_setup(tcp, state) \
+  (ptrace (PTRACE_GETREGS, tcp->pid, (char *) (state), 0))
+# define arg_finish_change(tcp, state) \
+  (ptrace (PTRACE_SETREGS, tcp->pid, (char *) (state), 0))
+
+# define get_arg0(tcp, state, valp) (*(valp) = (state)->r_o0, 0)
+# define get_arg1(tcp, state, valp) (*(valp) = (state)->r_o1, 0)
+# define set_arg0(tcp, state, val) ((state)->r_o0 = (val), 0)
+# define set_arg1(tcp, state, val) ((state)->r_o1 = (val), 0)
+
+#else
+
+# ifdef S390
+#  define arg0_offset	PT_ORIGGPR2
+#  define arg1_offset	PT_GPR2
+# elif defined (ALPHA) || defined (MIPS)
+#  define arg0_offset	REG_A0
+#  define arg1_offset	(REG_A0+1)
+# elif defined (POWERPC)
+#  define arg0_offset	(4*PT_ORIG_R3)
+#  define arg1_offset	(4*(1+PT_R3))
+# elif defined (HPPA)
+#  define arg0_offset	 PT_GR26
+#  define arg1_offset	 (PT_GR26-4)
+# else
+#  define arg0_offset	0
+#  define arg1_offset	4
+# endif
+
+typedef int arg_setup_state;
+
+# define arg_setup(tcp, state) (0)
+# define arg_finish_change(tcp, state)	0
+# define get_arg0(tcp, cookie, valp) \
+  (upeek ((tcp)->pid, arg0_offset, (valp)))
+# define get_arg1(tcp, cookie, valp) \
+  (upeek ((tcp)->pid, arg1_offset, (valp)))
+
+static int
+set_arg0 (struct tcb *tcp, void *cookie, long val)
+{
+  return ptrace (PTRACE_POKEUSER, tcp->pid, (char*)arg0_offset, val);
+}
+
+static int
+set_arg1 (struct tcb *tcp, void *cookie, long val)
+{
+  return ptrace (PTRACE_POKEUSER, tcp->pid, (char*)arg1_offset, val);
+}
+
+#endif
+
+
+int
+setbpt(tcp)
+struct tcb *tcp;
+{
+  extern int change_syscall(struct tcb *, int);
+  arg_setup_state state;
+
+  if (tcp->flags & TCB_BPTSET) {
+    fprintf(stderr, "PANIC: TCB already set in pid %u\n", tcp->pid);
+    return -1;
+  }
+
+  switch (tcp->scno)
+    {
+#ifdef SYS_fork
+    case SYS_fork:
+      if (arg_setup (tcp, &state) < 0
+	  || get_arg0 (tcp, &state, &tcp->inst[0]) < 0
+	  || get_arg1 (tcp, &state, &tcp->inst[1]) < 0
+	  || change_syscall(tcp, SYS_clone) < 0
+	  || set_arg0 (tcp, &state, CLONE_PTRACE) < 0
+	  || set_arg1 (tcp, &state, 0) < 0
+	  || arg_finish_change (tcp, &state) < 0)
+	return -1;
+      tcp->flags |= TCB_BPTSET;
+      return 0;
+#endif
+
+    case SYS_clone:
+    case SYS_clone2:
+      if ((tcp->u_arg[0] & CLONE_PTRACE) = 0
+	  && (arg_setup (tcp, &state) < 0
+	      || set_arg0 (tcp, &state, tcp->u_arg[0] | CLONE_PTRACE) < 0
+	      || arg_finish_change (tcp, &state) < 0))
+	return -1;
+      tcp->flags |= TCB_BPTSET;
+      tcp->inst[0] = tcp->u_arg[0];
+      tcp->inst[1] = tcp->u_arg[1];
+      return 0;
+
+    default:
+      fprintf(stderr, "PANIC: setbpt for syscall %ld on %u???\n",
+	      tcp->scno, tcp->pid);
+      break;
+    }
+
+  return -1;
+}
+
+int
+clearbpt(tcp)
+struct tcb *tcp;
+{
+  arg_setup_state state;
+  if (arg_setup (tcp, &state) < 0
+      || set_arg0 (tcp, &state, tcp->inst[0]) < 0
+      || set_arg1 (tcp, &state, tcp->inst[1]) < 0
+      || arg_finish_change (tcp, &state))
+    return -1;
+  tcp->flags &= ~TCB_BPTSET;
+  return 0;
+}
+
+#else
+
 int
 setbpt(tcp)
 struct tcb *tcp;
@@ -1181,8 +1369,6 @@
 		tcp->flags |= TCB_BPTSET;
 	} else {
 		/*
-		 * XXX Use break instead!
-		 *
 		 * Our strategy here is to replace the bundle that
 		 * contained the clone() syscall with a bundle of the
 		 * form:
@@ -1612,6 +1798,8 @@
 
 	return 0;
 }
+
+#endif
 
 #endif /* !USE_PROCFS */
 

