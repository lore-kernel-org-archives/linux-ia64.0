From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 29 Mar 2001 21:36:22 +0000
Subject: [Linux-ia64] another kdb patch
Message-Id: <marc-linux-ia64-105590693005371@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch does some more kdb cleanup and adds a command ("rd
k") to print the kernel regs.  I found this to be useful while
debugging the page-size related bug mentined in my earlier mail.

BTW: Thanks to Keith for maintaining kdb.  It would have been a lot
harder to track this bug down without kdb!

	--david

--- arch/ia64/kdb/kdbasupport.c~	Thu Mar 29 00:25:52 2001
+++ arch/ia64/kdb/kdbasupport.c	Thu Mar 29 09:13:23 2001
@@ -421,6 +421,22 @@
         ia64_srlz_d();
 }
 
+static void
+show_kernel_regs (void)
+{
+	unsigned long kr[8];
+	int i;
+
+	asm ("mov %0=ar.k0" : "=r"(kr[0])); asm ("mov %0=ar.k1" : "=r"(kr[1]));
+	asm ("mov %0=ar.k2" : "=r"(kr[2])); asm ("mov %0=ar.k3" : "=r"(kr[3]));
+	asm ("mov %0=ar.k4" : "=r"(kr[4])); asm ("mov %0=ar.k5" : "=r"(kr[5]));
+	asm ("mov %0=ar.k6" : "=r"(kr[6])); asm ("mov %0=ar.k7" : "=r"(kr[7]));
+
+	for (i = 0; i < 4; ++i)
+		kdb_printf(" kr%d: %016lx  kr%d: %016lx\n", 2*i, kr[2*i], 2*i+1, kr[2*i+1]);
+	kdb_printf("\n");
+}
+
 static int
 show_cur_stack_frame(struct pt_regs *regs, int regno, unsigned long *contents)
 {
@@ -576,9 +592,7 @@
 static const int nkdbreglist = sizeof(kdbreglist) / sizeof(struct kdbregs);
 
 int
-kdba_getregcontents(const char *regname, 
-		  struct pt_regs *regs,
-		  unsigned long *contents)
+kdba_getregcontents(const char *regname, struct pt_regs *regs, unsigned long *contents)
 {
 	int i;
 
@@ -597,23 +611,13 @@
 		get_fault_regs(&fr) ;
 		*contents = fr.isr ;
 		return 0 ;
-	} 
+	}
 
         if (strcmp(regname, "ksp") = 0) {
                 *contents = (unsigned long) (regs + 1);
                 return 0;
         }
 
-#if i386_sample_code
-	/* XXX need to verify this */
-	if (regname[0] = '%') {
-		/* User registers:  %%e[a-c]x, etc */
-		regname++;
-		regs = (struct pt_regs *)
-			(current->thread.ksp - sizeof(struct pt_regs));
-	}
-#endif /* i386_sample_code */
-
 	for (i=0; i<nkdbreglist; i++) {
 		if (strstr(kdbreglist[i].reg_name, regname))
 			break;
@@ -721,6 +725,7 @@
  *	rd	s	- valid stacked regs
  * 	rd 	%sstk	- gets switch stack addr. dump memory and search
  *	rd	d	- debug regs, may not be too useful
+ *	rd	k	- dump kernel regs
  *
  *	ARs		TB Done
  *	OTHERS		TB Decided ??
@@ -778,7 +783,7 @@
 		for(i=0; i<8; i+=2) {
 			kdb_printf("idr%d: 0x%16.16lx  idr%d: 0x%16.16lx\n", i, 
 					kdba_getdr(i), i+1, kdba_getdr(i+1));
-					
+
 		}
 		return 0;
 	}
@@ -797,6 +802,9 @@
 #endif /* i386_sample_code */
 	case 'i':
 		kdba_show_intregs();
+		break;
+	case 'k':
+		show_kernel_regs();
 		break;
 	case 'm':
 		break;

