From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 09 Aug 2004 04:50:43 +0000
Subject: pgd/pmd page error of kernel 2.6.8-rc3 when CONFIG_PREEMPT=y
Message-Id: <8126E4F969BA254AB43EA03C59F44E841990BC@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E8419909D@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Because of unexpected line break, resend the error log and the patch.

Aug  6 09:23:39 tpcc-el4a3 last message repeated 3 times
Aug  6 09:23:39 tpcc-el4a3 sshd(pam_unix)[2697]: session opened for user
root by (uid=3D0)
Aug  6 09:23:53 tpcc-el4a3 kernel: mm/memory.c:449: bad pgd
e0000003f45f4000.
Aug  6 09:23:53 tpcc-el4a3 kernel: mm/memory.c:128: bad pgd
e000000108a00000.
Aug  6 09:23:54 tpcc-el4a3 kernel: kernel BUG at mm/page_alloc.c:792!
Aug  6 09:23:54 tpcc-el4a3 kernel: rm[16480]: bugcheck! 0 [1]
Aug  6 09:23:54 tpcc-el4a3 kernel: Modules linked in:
Aug  6 09:23:54 tpcc-el4a3 kernel:
Aug  6 09:23:54 tpcc-el4a3 kernel: Pid: 16480, CPU 1, comm:
rm
Aug  6 09:23:54 tpcc-el4a3 kernel: psr : 0000101008026018 ifs :
8000000000000288 ip  : [<a0000001000e6ca0>]    Not tainted
Aug  6 09:23:54 tpcc-el4a3 kernel: ip is at __free_pages+0x140/0x160
Aug  6 09:23:54 tpcc-el4a3 kernel: unat: 0000000000000000 pfs :
0000000000000288 rsc : 0000000000000003
Aug  6 09:23:54 tpcc-el4a3 kernel: rnat: 0009804c8a70033f bsps:
00000000000bf2fd pr  : 5666a5a655a6a969
Aug  6 09:23:54 tpcc-el4a3 kernel: ldrs: 0000000000000000 ccv :
0000000000000004 fpsr: 0009804c8a70033f
Aug  6 09:23:56 tpcc-el4a3 kernel: csd : 0000000000000000 ssd :
0000000000000000
Aug  6 09:23:56 tpcc-el4a3 kernel: b0  : a0000001000e6ca0 b6  :
a0000001000e42a0 b7  : a00000010008dae0
Aug  6 09:23:56 tpcc-el4a3 kernel: f6  : 1003e0fc0fc0fc0fc0fc1 f7  :
0ffdc8dc0000000000000
Aug  6 09:23:56 tpcc-el4a3 kernel: f8  : 1003e0000000000000280 f9  :
1003e00000000000028a0
Aug  6 09:23:56 tpcc-el4a3 kernel: f10 : 1003e0000000010400000 f11 :
1003e000000003c893320
Aug  6 09:23:56 tpcc-el4a3 kernel: r1  : a000000100aba240 r2  :
0000000000000001 r3  : e000000108c70ec0
Aug  6 09:23:56 tpcc-el4a3 kernel: r8  : 0000000000000023 r9  :
0000000000000001 r10 : 0000000000000002
Aug  6 09:23:56 tpcc-el4a3 kernel: r11 : 0000000000000003 r12 :
e000000108c77d30 r13 : e000000108c70000
Aug  6 09:23:56 tpcc-el4a3 kernel: r14 : 0000000000000004 r15 :
0000000000004000 r16 : e000000108c70ea0
Aug  6 09:23:57 tpcc-el4a3 kernel: r17 : e000000105fe7de8 r18 :
0000000000000002 r19 : 0000000000000004
Aug  6 09:23:57 tpcc-el4a3 kernel: r20 : 0000000000000001 r21 :
0000000000000000 r22 : 0000000000004000
Aug  6 09:23:57 tpcc-el4a3 kernel: r23 : e000000108c77cf0 r24 :
0000000000000003 r25 : e000000108c70eb4
Aug  6 09:23:57 tpcc-el4a3 kernel: r26 : e000000108c70eb0 r27 :
e000000108c70ec0 r28 : 0000000000000000
Aug  6 09:23:57 tpcc-el4a3 kernel: r29 : e000000108c70ec0 r30 :
0000001008022018 r31 : 0000000000000004
Aug  6 09:23:57 tpcc-el4a3 kernel:
Aug  6 09:23:57 tpcc-el4a3 kernel: Call Trace:
Aug  6 09:23:57 tpcc-el4a3 kernel:  [<a000000100015d60>]
show_stack+0x80/0xa0
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77900 bsp=E000000108c71370
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010003c0a0>] die+0x1c0/0x2a0
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77ad0 bsp=E000000108c71338
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010003c400>]
ia64_bad_break+0x220/0x340
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77ad0 bsp=E000000108c71310
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010000e4e0>]
ia64_leave_kernel+0x0/0x270
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77b60 bsp=E000000108c71310
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a0000001000e6ca0>]
__free_pages+0x140/0x160
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c712d0
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a000000100058fa0>]
check_pgt_cache+0x120/0x160
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c71298
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010010c740>]
unmap_region+0x2c0/0x400
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c71230
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010010ce50>]
do_munmap+0x290/0x3a0
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77df0 bsp=E000000108c711e8
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010010aeb0>]
do_mmap_pgoff+0x430/0xd60
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77e00 bsp=E000000108c71138
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010003a350>]
sys_mmap+0x210/0x320
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77e30 bsp=E000000108c710a8
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010000e340>]
ia64_ret_from_syscall+0x0/0x20
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77e30 bsp=E000000108c710a8
Aug  6 09:23:58 tpcc-el4a3 kernel:  <6>note: rm[16480] exited with
preempt_count 1
Aug  6 09:23:58 tpcc-el4a3 kernel: bad: scheduling while atomic!
Aug  6 09:23:58 tpcc-el4a3 kernel:
Aug  6 09:23:58 tpcc-el4a3 kernel: Call Trace:
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a000000100015d60>]
show_stack+0x80/0xa0
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c778d0 bsp=E000000108c71568
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010059aea0>]
schedule+0x13e0/0x1400
Aug  6 09:23:58 tpcc-el4a3 kernel:
sp=E000000108c77aa0 bsp=E000000108c71448
Aug  6 09:23:58 tpcc-el4a3 kernel:  [<a00000010059c8d0>]
rwsem_down_read_failed+0x250/0x540
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77ab0 bsp=E000000108c713f0
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010009a6f0>]
do_exit+0x1f0/0xd40
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77ad0 bsp=E000000108c71370
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010003c140>] die+0x260/0x2a0
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77ad0 bsp=E000000108c71338
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010003c400>]
ia64_bad_break+0x220/0x340
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77ad0 bsp=E000000108c71310
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010000e4e0>]
ia64_leave_kernel+0x0/0x270
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77b60 bsp=E000000108c71310
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a0000001000e6ca0>]
__free_pages+0x140/0x160
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c712d0
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a000000100058fa0>]
check_pgt_cache+0x120/0x160
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c71298
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010010c740>]
unmap_region+0x2c0/0x400
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77d30 bsp=E000000108c71230
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010010ce50>]
do_munmap+0x290/0x3a0
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77df0 bsp=E000000108c711e8
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010010aeb0>]
do_mmap_pgoff+0x430/0xd60
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77e00 bsp=E000000108c71138
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010003a350>]
sys_mmap+0x210/0x320
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77e30 bsp=E000000108c710a8
Aug  6 09:23:59 tpcc-el4a3 kernel:  [<a00000010000e340>]
ia64_ret_from_syscall+0x0/0x20
Aug  6 09:23:59 tpcc-el4a3 kernel:
sp=E000000108c77e30 bsp=E000000108c710a8

Broadcast message from root (pts/1) (Fri Aug  6 09:24:05 2004):

The system is going down for reboot NOW!
Aug  6 09:24:05 tpcc-el4a3 shutdown: shutting down for system reboot
Aug  6 09:24:06 tpcc-el4a3 init: Switching to runlevel: 6
Aug  6 09:24:12 tpcc-el4a3 messagebus: messagebus -TERM succeeded
Aug  6 09:24:12 tpcc-el4a3 atd: atd shutdown succeeded


Here is the patch to fix the bug.
diff -Nraup a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	2004-08-06 12:46:36.765790499 +0800
+++ b/arch/ia64/mm/init.c	2004-08-06 12:47:27.169110194 +0800
@@ -63,6 +63,7 @@ check_pgt_cache (void)
 	low =3D pgt_cache_water[0];
 	high =3D pgt_cache_water[1];
=20
+	preempt_disable();
 	if (pgtable_cache_size > (u64) high) {
 		do {
 			if (pgd_quicklist)
@@ -71,6 +72,7 @@ check_pgt_cache (void)
 				free_page((unsigned
long)pmd_alloc_one_fast(0, 0));
 		} while (pgtable_cache_size > (u64) low);
 	}
+	preempt_enable();
 }
=20
 void
diff -Nraup a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
--- a/include/asm-ia64/pgalloc.h	2004-08-06 12:46:48.180829421
+0800
+++ b/include/asm-ia64/pgalloc.h	2004-08-06 12:47:27.170086756
+0800
@@ -37,14 +37,20 @@
 static inline pgd_t*
 pgd_alloc_one_fast (struct mm_struct *mm)
 {
-	unsigned long *ret =3D pgd_quicklist;
+	unsigned long *ret =3D NULL;
=20
+	preempt_disable();
+
+	ret =3D pgd_quicklist;
 	if (likely(ret !=3D NULL)) {
 		pgd_quicklist =3D (unsigned long *)(*ret);
 		ret[0] =3D 0;
 		--pgtable_cache_size;
 	} else
 		ret =3D NULL;
+
+	preempt_enable();
+
 	return (pgd_t *) ret;
 }
=20
@@ -65,9 +71,11 @@ pgd_alloc (struct mm_struct *mm)
 static inline void
 pgd_free (pgd_t *pgd)
 {
+	preempt_disable();
 	*(unsigned long *)pgd =3D (unsigned long) pgd_quicklist;
 	pgd_quicklist =3D (unsigned long *) pgd;
 	++pgtable_cache_size;
+	preempt_enable();
 }
=20
 static inline void
@@ -80,13 +88,19 @@ pgd_populate (struct mm_struct *mm, pgd_
 static inline pmd_t*
 pmd_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
 {
-	unsigned long *ret =3D (unsigned long *)pmd_quicklist;
+	unsigned long *ret =3D NULL;
=20
+	preempt_disable();
+
+	ret =3D (unsigned long *)pmd_quicklist;
 	if (likely(ret !=3D NULL)) {
 		pmd_quicklist =3D (unsigned long *)(*ret);
 		ret[0] =3D 0;
 		--pgtable_cache_size;
 	}
+
+	preempt_enable();
+
 	return (pmd_t *)ret;
 }
=20
@@ -103,9 +117,11 @@ pmd_alloc_one (struct mm_struct *mm, uns
 static inline void
 pmd_free (pmd_t *pmd)
 {
+	preempt_disable();
 	*(unsigned long *)pmd =3D (unsigned long) pmd_quicklist;
 	pmd_quicklist =3D (unsigned long *) pmd;
 	++pgtable_cache_size;
+	preempt_enable();
 }
=20
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
Signed-off-by: Zou Nanhai <nanhai.zou@intel.com>

