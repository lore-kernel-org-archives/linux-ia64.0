From: nomura@hpc.bs1.fc.nec.co.jp
Date: Tue, 31 Jul 2001 06:36:18 +0000
Subject: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

2.4.7 has problem in booting due to ar.k0 rewrite.
Here is my proposal to fix it.

It seems that new ar.k0 initialization in 2.4.7 changes ar.k0 value
set by SAL and results in access to illegal address by SAL.
Since ar.k0 is already set up properly by SAL for their use, 
shouldn't we change it in setup_arch()?

To be more precise, on our platform, SAL sets ar.k0 to 0x80000ffffc000000
for uncached access to 0xffffc000000. Linux changes it to 0xffffc000000
not taking SAL address mapping into consideration.

Attached patch changes setup_arch() to keep ar.k0 value to SAL setting.
I confirmed the patch working both with Intel SAL and our platform's SAL.

--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.


Index: arch/ia64/kernel/setup.c
=================================RCS file: /home/cvsadm/cvsroot/linux/arch/ia64/kernel/setup.c,v
retrieving revision 1.1.1.7.6.2
diff -u -r1.1.1.7.6.2 setup.c
--- arch/ia64/kernel/setup.c	2001/07/27 09:30:29	1.1.1.7.6.2
+++ arch/ia64/kernel/setup.c	2001/07/31 05:15:09
@@ -314,10 +314,9 @@
 	 *  AR.KR0 if no appropriate entry is found in the memory map.
 	 */
 	ia64_iobase = efi_get_iobase();
-	if (ia64_iobase)
-		/* set AR.KR0 since this is all we use it for anyway */
-		ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase);
-	else {
+	if (ia64_iobase) {
+		/* do nothing */
+	} else {
 		ia64_iobase = ia64_get_kr(IA64_KR_IO_BASE);
 		printk("No I/O port range found in EFI memory map, falling back to AR.KR0\n");
 		printk("I/O port base = 0x%lx\n", ia64_iobase);

