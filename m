From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 02 Sep 2000 02:24:19 +0000
Subject: [Linux-ia64] 2.4.0 do_fork() change, all architectures - take 2
Message-Id: <marc-linux-ia64-105590678205446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205445@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

DaveM pointed out that my 2.4.0-test8-pre1 do_fork patch would generate
better sparc assembler if the extra parameter to do_fork was added at
the end instead of in the middle.  So change all do_fork(flags,sp,0,&regs)
to do_fork(flags,sp,&regs,0);

I'm not going to mail the complete patch again, you can get it from
ftp://ftp.ocs.com.au/pub/do_fork-2.4.0-test8-take2.gz.  The only
significant difference is this bit to IA64, untested.

Index: 0-test8-pre1.1/arch/ia64/kernel/entry.S
--- 0-test8-pre1.1/arch/ia64/kernel/entry.S Tue, 15 Aug 2000 17:50:48 +1000 kaos (linux-2.4/c/c/16_entry.S 1.3.1.1.1.2 644)
+++ 0-test8-pre1.2(w)/arch/ia64/kernel/entry.S Sat, 02 Sep 2000 12:49:16 +1100 kaos (linux-2.4/c/c/16_entry.S 1.3.1.1.1.2 644)
@@ -68,8 +68,8 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	UNW(.body)
 	mov out1=in1
-	mov out2=in2
-	adds out3=IA64_SWITCH_STACK_SIZE+16,sp	// out3 = &regs
+	mov out3=in2
+	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	mov out0=in0				// out0 = clone_flags
 	br.call.sptk.few rp=do_fork
 .ret1:	UNW(.restore sp)
@@ -87,8 +87,8 @@
 	mov loc1=r16				// save ar.pfs across do_fork
 	UNW(.body)
 	mov out1=in1
-	mov out2=0
-	adds out3=IA64_SWITCH_STACK_SIZE+16,sp	// out3 = &regs
+	mov out3=0
+	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	mov out0=in0				// out0 = clone_flags
 	br.call.sptk.few rp=do_fork
 .ret2:	UNW(.restore sp)
Index: 0-test8-pre1.1/arch/ia64/ia32/ia32_entry.S
--- 0-test8-pre1.1/arch/ia64/ia32/ia32_entry.S Tue, 15 Aug 2000 17:50:48 +1000 kaos (linux-2.4/c/c/25_ia32_entry 1.3.1.1 644)
+++ 0-test8-pre1.2(w)/arch/ia64/ia32/ia32_entry.S Sat, 02 Sep 2000 12:49:58 +1100 kaos (linux-2.4/c/c/25_ia32_entry 1.3.1.1 644)
@@ -91,8 +91,8 @@
 	UNW(.body)
 
 	mov out1=0
-	mov out2=0
-	adds out3=IA64_SWITCH_STACK_SIZE+16,sp
+	mov out3=0
+	adds out2=IA64_SWITCH_STACK_SIZE+16,sp	// out2 = &regs
 	br.call.sptk.few rp=do_fork
 .ret3:	mov ar.pfs=loc1
 	UNW(.restore sp)


