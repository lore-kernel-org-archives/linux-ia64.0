From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 11 Dec 2002 05:05:45 +0000
Subject: [Linux-ia64] Extra do_fork arg for clone2
Message-Id: <marc-linux-ia64-105590709805541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Due to the recent changes to clone flags by Ingo Molnar (see
http://www.gelato.unsw.edu.au/~ianw/clone2.txt if anyone missed the
thread) we need an extra argument to do_fork.  this doesn't seem to be
in the 2.5.50 pre-patch.

suggested patch below.

thanks
-i
ianw@gelato.unsw.edu.au

--- 1.24/arch/ia64/kernel/entry.S	Mon Nov 25 10:27:51 2002
+++ 1.25/arch/ia64/kernel/entry.S	Wed Dec 11 15:04:10 2002
@@ -91,11 +91,11 @@
 END(ia64_execve)

 /*
- * sys_clone2(u64 flags, u64 ustack_base, u64 ustack_size, u64 user_tid, u64 tls)
+ * sys_clone2(u64 flags, u64 ustack_base, u64 ustack_size, u64 parent_tidptr, u64 child_tidptr, u64 tls)
  */
 GLOBAL_ENTRY(sys_clone2)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
-	alloc r16=ar.pfs,5,2,5,0
+	alloc r16=ar.pfs,6,2,6,0
 	DO_SAVE_SWITCH_STACK
 	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=rp
@@ -104,9 +104,10 @@
 	mov out1=in1
 	mov out3=in2
 	tbit.nz p6,p0=in0,CLONE_SETTLS_BIT
-	mov out4=in3				// valid only w/CLONE_SETTID and/or CLONE_CLEARTID
+	mov out4=in3				// parent_tidptr
+	mov out5=in4				// child_tidptr
 	;;
-(p6)	st8 [r2]=in4				// store TLS in r13 (tp)
+(p6)	st8 [r2]=in5				// store TLS in r13 (tp)
 	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	dep out0=0,in0,CLONE_IDLETASK_BIT,1	// out0 = clone_flags & ~CLONE_IDLETASK
 	br.call.sptk.many rp=do_fork

