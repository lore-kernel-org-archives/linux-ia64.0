From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 23 Jul 2003 16:56:34 +0000
Subject: PATCH: gcc 3.3 support and quota workaround
MIME-Version: 1
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Message-Id: <marc-linux-ia64-105897942901816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I am using gcc 3.3 to build the ia64 2.4 kernel from

http://lia64.bkbits.net/linux-ia64-2.4

Gcc 3.3 doesn't like multi-line asm statement. I am enclosing a patch
here.

Also the kernel won't compile with

CONFIG_QUOTA=y

in .config since INIT_QUOTA_MODULE_NAMES is not defined anywhere. I
looked at fs/dquot.c. There are some codes which weren't in 2.4.22-pre6
nor 2.4.22-pre7. Where did they come from? I use the patch enclosed to
get the kernel to compile.


H.J.

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gcc-3.3.patch"

--- linux/include/asm-ia64/xor.h.gcc-3.3	Tue Jun 24 09:11:27 2003
+++ linux/include/asm-ia64/xor.h	Tue Jun 24 10:28:20 2003
@@ -23,255 +23,255 @@ extern void xor_ia64_4(unsigned long, un
 extern void xor_ia64_5(unsigned long, unsigned long *, unsigned long *,
 		       unsigned long *, unsigned long *, unsigned long *);
 
-asm ("
-	.text
-
-	// Assume L2 memory latency of 6 cycles.
-
-	.proc xor_ia64_2
-xor_ia64_2:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 3, 0, 13, 16
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], d[2]
-	.rotp p[6+2]
-0:	 { .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mfb
-(p[6+1])  st8.nta [r8] = d[1], 8
-	  nop.f 0
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_2
-
-	.proc xor_ia64_3
-xor_ia64_3:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 4, 0, 20, 24
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	  ;;
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], s3[6]
-	}
-	{ .bbb
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_3
-
-	.proc xor_ia64_4
-xor_ia64_4:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 5, 0, 27, 32
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	}
-	{ .mfb
-	  mov r19 = in4
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[0])	  ld8.nta s4[0] = [r19], 8
-(p[6])	  xor r20 = s3[6], s4[6]
-	  ;;
-	}
-	{ .mib
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], r20
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_4
-
-	.proc xor_ia64_5
-xor_ia64_5:
-	.prologue
-	.fframe 0
-	{ .mii
-	  .save ar.pfs, r31
-	  alloc r31 = ar.pfs, 6, 0, 34, 40
-	  .save ar.lc, r30
-	  mov r30 = ar.lc
-	  .save pr, r29
-	  mov r29 = pr
-	  ;;
-	}
-	.body
-	{ .mii
-	  mov r8 = in1
-	  mov ar.ec = 6 + 2
-	  shr in0 = in0, 3
-	  ;;
-	}
-	{ .mmi
-	  adds in0 = -1, in0
-	  mov r16 = in1
-	  mov r17 = in2
-	  ;;
-	}
-	{ .mii
-	  mov r18 = in3
-	  mov ar.lc = in0
-	  mov pr.rot = 1 << 16
-	}
-	{ .mib
-	  mov r19 = in4
-	  mov r20 = in5
-	  ;;
-	}
-	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], s5[6+1], d[2]
-	.rotp p[6+2]
-0:	{ .mmi
-(p[0])	  ld8.nta s1[0] = [r16], 8
-(p[0])	  ld8.nta s2[0] = [r17], 8
-(p[6])	  xor d[0] = s1[6], s2[6]
-	}
-	{ .mmi
-(p[0])	  ld8.nta s3[0] = [r18], 8
-(p[0])	  ld8.nta s4[0] = [r19], 8
-(p[6])	  xor r21 = s3[6], s4[6]
-	  ;;
-	}
-	{ .mmi
-(p[0])	  ld8.nta s5[0] = [r20], 8
-(p[6+1])  st8.nta [r8] = d[1], 8
-(p[6])	  xor d[0] = d[0], r21
-	  ;;
-	}
-	{ .mfb
-(p[6])	  xor d[0] = d[0], s5[6]
-	  nop.f 0
-	  br.ctop.dptk.few 0b
-	  ;;
-	}
-	{ .mii
-	  mov ar.lc = r30
-	  mov pr = r29, -1
-	}
-	{ .bbb
-	  br.ret.sptk.few rp
-	}
-	.endp xor_ia64_5
-");
+asm (
+"	.text\n"
+"\n"
+"	// Assume L2 memory latency of 6 cycles.\n"
+"\n"
+"	.proc xor_ia64_2\n"
+"xor_ia64_2:\n"
+"	.prologue\n"
+"	.fframe 0\n"
+"	{ .mii\n"
+"	  .save ar.pfs, r31\n"
+"	  alloc r31 = ar.pfs, 3, 0, 13, 16\n"
+"	  .save ar.lc, r30\n"
+"	  mov r30 = ar.lc\n"
+"	  .save pr, r29\n"
+"	  mov r29 = pr\n"
+"	  ;;\n"
+"	}\n"
+"	.body\n"
+"	{ .mii\n"
+"	  mov r8 = in1\n"
+"	  mov ar.ec = 6 + 2\n"
+"	  shr in0 = in0, 3\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"	  adds in0 = -1, in0\n"
+"	  mov r16 = in1\n"
+"	  mov r17 = in2\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov ar.lc = in0\n"
+"	  mov pr.rot = 1 << 16\n"
+"	  ;;\n"
+"	}\n"
+"	.rotr s1[6+1], s2[6+1], d[2]\n"
+"	.rotp p[6+2]\n"
+"0:	 { .mmi\n"
+"(p[0])	  ld8.nta s1[0] = [r16], 8\n"
+"(p[0])	  ld8.nta s2[0] = [r17], 8\n"
+"(p[6])	  xor d[0] = s1[6], s2[6]\n"
+"	}\n"
+"	{ .mfb\n"
+"(p[6+1])  st8.nta [r8] = d[1], 8\n"
+"	  nop.f 0\n"
+"	  br.ctop.dptk.few 0b\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov ar.lc = r30\n"
+"	  mov pr = r29, -1\n"
+"	}\n"
+"	{ .bbb\n"
+"	  br.ret.sptk.few rp\n"
+"	}\n"
+"	.endp xor_ia64_2\n"
+"\n"
+"	.proc xor_ia64_3\n"
+"xor_ia64_3:\n"
+"	.prologue\n"
+"	.fframe 0\n"
+"	{ .mii\n"
+"	  .save ar.pfs, r31\n"
+"	  alloc r31 = ar.pfs, 4, 0, 20, 24\n"
+"	  .save ar.lc, r30\n"
+"	  mov r30 = ar.lc\n"
+"	  .save pr, r29\n"
+"	  mov r29 = pr\n"
+"	  ;;\n"
+"	}\n"
+"	.body\n"
+"	{ .mii\n"
+"	  mov r8 = in1\n"
+"	  mov ar.ec = 6 + 2\n"
+"	  shr in0 = in0, 3\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"	  adds in0 = -1, in0\n"
+"	  mov r16 = in1\n"
+"	  mov r17 = in2\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov r18 = in3\n"
+"	  mov ar.lc = in0\n"
+"	  mov pr.rot = 1 << 16\n"
+"	  ;;\n"
+"	}\n"
+"	.rotr s1[6+1], s2[6+1], s3[6+1], d[2]\n"
+"	.rotp p[6+2]\n"
+"0:	{ .mmi\n"
+"(p[0])	  ld8.nta s1[0] = [r16], 8\n"
+"(p[0])	  ld8.nta s2[0] = [r17], 8\n"
+"(p[6])	  xor d[0] = s1[6], s2[6]\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"(p[0])	  ld8.nta s3[0] = [r18], 8\n"
+"(p[6+1])  st8.nta [r8] = d[1], 8\n"
+"(p[6])	  xor d[0] = d[0], s3[6]\n"
+"	}\n"
+"	{ .bbb\n"
+"	  br.ctop.dptk.few 0b\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov ar.lc = r30\n"
+"	  mov pr = r29, -1\n"
+"	}\n"
+"	{ .bbb\n"
+"	  br.ret.sptk.few rp\n"
+"	}\n"
+"	.endp xor_ia64_3\n"
+"\n"
+"	.proc xor_ia64_4\n"
+"xor_ia64_4:\n"
+"	.prologue\n"
+"	.fframe 0\n"
+"	{ .mii\n"
+"	  .save ar.pfs, r31\n"
+"	  alloc r31 = ar.pfs, 5, 0, 27, 32\n"
+"	  .save ar.lc, r30\n"
+"	  mov r30 = ar.lc\n"
+"	  .save pr, r29\n"
+"	  mov r29 = pr\n"
+"	  ;;\n"
+"	}\n"
+"	.body\n"
+"	{ .mii\n"
+"	  mov r8 = in1\n"
+"	  mov ar.ec = 6 + 2\n"
+"	  shr in0 = in0, 3\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"	  adds in0 = -1, in0\n"
+"	  mov r16 = in1\n"
+"	  mov r17 = in2\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov r18 = in3\n"
+"	  mov ar.lc = in0\n"
+"	  mov pr.rot = 1 << 16\n"
+"	}\n"
+"	{ .mfb\n"
+"	  mov r19 = in4\n"
+"	  ;;\n"
+"	}\n"
+"	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], d[2]\n"
+"	.rotp p[6+2]\n"
+"0:	{ .mmi\n"
+"(p[0])	  ld8.nta s1[0] = [r16], 8\n"
+"(p[0])	  ld8.nta s2[0] = [r17], 8\n"
+"(p[6])	  xor d[0] = s1[6], s2[6]\n"
+"	}\n"
+"	{ .mmi\n"
+"(p[0])	  ld8.nta s3[0] = [r18], 8\n"
+"(p[0])	  ld8.nta s4[0] = [r19], 8\n"
+"(p[6])	  xor r20 = s3[6], s4[6]\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mib\n"
+"(p[6+1])  st8.nta [r8] = d[1], 8\n"
+"(p[6])	  xor d[0] = d[0], r20\n"
+"	  br.ctop.dptk.few 0b\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov ar.lc = r30\n"
+"	  mov pr = r29, -1\n"
+"	}\n"
+"	{ .bbb\n"
+"	  br.ret.sptk.few rp\n"
+"	}\n"
+"	.endp xor_ia64_4\n"
+"\n"
+"	.proc xor_ia64_5\n"
+"xor_ia64_5:\n"
+"	.prologue\n"
+"	.fframe 0\n"
+"	{ .mii\n"
+"	  .save ar.pfs, r31\n"
+"	  alloc r31 = ar.pfs, 6, 0, 34, 40\n"
+"	  .save ar.lc, r30\n"
+"	  mov r30 = ar.lc\n"
+"	  .save pr, r29\n"
+"	  mov r29 = pr\n"
+"	  ;;\n"
+"	}\n"
+"	.body\n"
+"	{ .mii\n"
+"	  mov r8 = in1\n"
+"	  mov ar.ec = 6 + 2\n"
+"	  shr in0 = in0, 3\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"	  adds in0 = -1, in0\n"
+"	  mov r16 = in1\n"
+"	  mov r17 = in2\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov r18 = in3\n"
+"	  mov ar.lc = in0\n"
+"	  mov pr.rot = 1 << 16\n"
+"	}\n"
+"	{ .mib\n"
+"	  mov r19 = in4\n"
+"	  mov r20 = in5\n"
+"	  ;;\n"
+"	}\n"
+"	.rotr s1[6+1], s2[6+1], s3[6+1], s4[6+1], s5[6+1], d[2]\n"
+"	.rotp p[6+2]\n"
+"0:	{ .mmi\n"
+"(p[0])	  ld8.nta s1[0] = [r16], 8\n"
+"(p[0])	  ld8.nta s2[0] = [r17], 8\n"
+"(p[6])	  xor d[0] = s1[6], s2[6]\n"
+"	}\n"
+"	{ .mmi\n"
+"(p[0])	  ld8.nta s3[0] = [r18], 8\n"
+"(p[0])	  ld8.nta s4[0] = [r19], 8\n"
+"(p[6])	  xor r21 = s3[6], s4[6]\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mmi\n"
+"(p[0])	  ld8.nta s5[0] = [r20], 8\n"
+"(p[6+1])  st8.nta [r8] = d[1], 8\n"
+"(p[6])	  xor d[0] = d[0], r21\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mfb\n"
+"(p[6])	  xor d[0] = d[0], s5[6]\n"
+"	  nop.f 0\n"
+"	  br.ctop.dptk.few 0b\n"
+"	  ;;\n"
+"	}\n"
+"	{ .mii\n"
+"	  mov ar.lc = r30\n"
+"	  mov pr = r29, -1\n"
+"	}\n"
+"	{ .bbb\n"
+"	  br.ret.sptk.few rp\n"
+"	}\n"
+"	.endp xor_ia64_5\n"
+);
 
 static struct xor_block_template xor_block_ia64 = {
 	name: "ia64",

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="quota.patch"

--- linux/fs/dquot.c.quota	Mon Jul 21 21:17:25 2003
+++ linux/fs/dquot.c	Mon Jul 21 21:39:42 2003
@@ -68,13 +68,17 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
+#if 0
 #include <linux/kmod.h>
+#endif
 
 #include <asm/uaccess.h>
 
 static char *quotatypes[] = INITQFNAMES;
 static struct quota_format_type *quota_formats;	/* List of registered formats */
+#if 0
 static struct quota_module_name module_names[] = INIT_QUOTA_MODULE_NAMES;
+#endif
 
 int register_quota_format(struct quota_format_type *fmt)
 {
@@ -102,6 +106,7 @@ static struct quota_format_type *find_qu
 
 	lock_kernel();
 	for (actqf = quota_formats; actqf && actqf->qf_fmt_id != id; actqf = actqf->qf_next);
+#if 0
 	if (!actqf || !try_inc_mod_count(actqf->qf_owner)) {
 		int qm;
 
@@ -115,6 +120,10 @@ static struct quota_format_type *find_qu
 			actqf = NULL;
 	}
 out:
+#else
+	if (actqf && !try_inc_mod_count(actqf->qf_owner))
+		actqf = NULL;
+#endif
 	unlock_kernel();
 	return actqf;
 }

--n8g4imXOkfNTN/H1--
