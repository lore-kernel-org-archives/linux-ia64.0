From: John Byrne <john.l.byrne@hp.com>
Date: Sat, 16 Aug 2003 00:07:41 +0000
Subject: [PATCH] Fix prologue directives for sys_clone() and sys_clone2()]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020203040406090500060301"
Message-Id: <marc-linux-ia64-106099247521466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020203040406090500060301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


To my limited understanding, the GRSAVE portions of the .prologue
directives for sys_clone() and sys_clone2() are incorrect. This patch, 
against 2.6.0-test3, fixes them.

I also wonder whether the the continued usage of the 2 argument form of
clone() in kernel_thread() should be considered "bad form". Admittedly,
the other arguments are don't-care as long as the various CLONE_ flags 
(which kernel_thread() does not mask off) are not set , but it just 
feels wrong. I guess I wouldn't be a programmer if I didn't like to pick 
nits.

John Byrne




--------------020203040406090500060301
Content-Type: text/plain;
 name="diff.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff.txt"

diff -Nar -u4 -x '*~' linux-2.6.0-test3/arch/ia64/kernel/entry.S new/arch/ia64/kernel/entry.S
--- linux-2.6.0-test3/arch/ia64/kernel/entry.S	2003-08-08 21:34:02.000000000 -0700
+++ new/arch/ia64/kernel/entry.S	2003-08-15 16:39:29.000000000 -0700
@@ -112,9 +112,9 @@
  * sys_clone2(u64 flags, u64 ustack_base, u64 ustack_size, u64 parent_tidptr, u64 child_tidptr,
  *	      u64 tls)
  */
 GLOBAL_ENTRY(sys_clone2)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6)
 	alloc r16=ar.pfs,6,2,6,0
 	DO_SAVE_SWITCH_STACK
 	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=rp
@@ -141,9 +141,9 @@
  * sys_clone(u64 flags, u64 ustack_base, u64 parent_tidptr, u64 child_tidptr, u64 tls)
  *	Deprecated.  Use sys_clone2() instead.
  */
 GLOBAL_ENTRY(sys_clone)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
 	alloc r16=ar.pfs,5,2,6,0
 	DO_SAVE_SWITCH_STACK
 	adds r2=PT(R16)+IA64_SWITCH_STACK_SIZE+16,sp
 	mov loc0=rp



--------------020203040406090500060301--

