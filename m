From: Don Dugger <n0ano@valinux.com>
Date: Tue, 08 May 2001 21:27:13 +0000
Subject: Re: [Linux-ia64] [Announce] kdb v1.8 updates are available
MIME-Version: 1
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Message-Id: <marc-linux-ia64-105590693005549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii

Keith-

Here's a patch to the IA64 version of KDB that fixes two pet peeves
of mine:

1)  Enable ANY command (especially `ss') to be repeated by a simple
carriage return.  (I didn't implement one of your wish list items,
only allow certain commands to be repeated.  The cleanest way I could
think of to do this is to add a flag to `kdb_register' to indicate
this and, as this routine is an externally exported interface, I didn't
feel comfortable changing it right now.)

2)  Change `kdb_id1' to only print out the target instruction rather
than the entire bundle.  It's really tough to single step through a
program when 3 single steps in a row print out the same instruction
bundle.

On Fri, Apr 27, 2001 at 10:18:45AM +1000, Keith Owens wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Content-Type: text/plain; charset=us-ascii
> 
> These updates to kdb have had minimal testing, they compile and boot
> for me(TM).
> 
> http://oss.sgi.com/projects/kdb/download/
> 
>   ix86/
>     kdb-v1.8-2.4.2-ac28.gz
>     kdb-v1.8-2.4.3.gz
>     kdb-v1.8-2.4.3-ac14.gz
>     kdb-v1.8-2.4.4-pre7.gz
> 
>   ia64/
>     kdb-v1.8-2.4.3-ia64-010405.gz
> 
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.0.3 (GNU/Linux)
> Comment: Exmh version 2.1.1 10/15/1999
> 
> iD8DBQE66Lrki4UHNye0ZOoRAgRGAJ44b1+nky5+uNJhWD93+bcOkQfxcgCg0RPg
> xpsQqw7whImmdGaY9+QB8AM=
> =Huto
> -----END PGP SIGNATURE-----
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_0508.l"

Index: arch/ia64/kdb/kdba_bp.c
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/arch/ia64/kdb/Attic/kdba_bp.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 kdba_bp.c
--- arch/ia64/kdb/kdba_bp.c	2001/05/04 20:40:51	1.1.2.1
+++ arch/ia64/kdb/kdba_bp.c	2001/05/04 22:34:22
@@ -174,7 +174,7 @@
 			kdb_machreg_t pc = ef->cr_iip + ia64_psr(ef)->ri * 6;
 			kdb_printf("SS trap at ");
 			kdb_symbol_print(pc, NULL, KDB_SP_DEFAULT|KDB_SP_NEWLINE);
-			kdb_id1(ef->cr_iip);
+			kdb_id1(pc);
 			KDB_STATE_CLEAR(DOING_SS);
 		}
 
Index: arch/ia64/kdb/kdba_id.c
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/arch/ia64/kdb/Attic/kdba_id.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 kdba_id.c
--- arch/ia64/kdb/kdba_id.c	2001/05/04 20:40:51	1.1.2.1
+++ arch/ia64/kdb/kdba_id.c	2001/05/08 20:46:50
@@ -244,11 +244,19 @@
 {
 	int ret;
 	int byte=0;
+	int off = 0;
+
+	dip->fprintf_func = dip->fprintf_dummy;
+	off = pc & 0xf;
 	kdba_check_pc(&pc);
 	while (byte < 16) {
+		if (byte == off)
+			dip->fprintf_func = kdb_dis_fprintf;
+		else
+			dip->fprintf_func = dip->fprintf_dummy;
 		kdba_dis_printaddr(pc+byte, dip);
 		ret = print_insn_ia64((kdb_machreg_t)(pc+byte), dip);
-		kdb_printf("\n");
+		dip->fprintf_func(dip->stream, "\n");
 		if (ret < 0)
 			break;
 		byte += ret;
Index: include/linux/dis-asm.h
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/include/linux/Attic/dis-asm.h,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 dis-asm.h
--- include/linux/dis-asm.h	2001/05/04 20:41:03	1.1.2.1
+++ include/linux/dis-asm.h	2001/05/08 20:44:52
@@ -67,6 +67,7 @@
 
 typedef struct disassemble_info {
   fprintf_ftype fprintf_func;
+  fprintf_ftype fprintf_dummy;
   PTR stream;
   PTR application_data;
 
Index: include/linux/kdbprivate.h
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/include/linux/Attic/kdbprivate.h,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 kdbprivate.h
--- include/linux/kdbprivate.h	2001/05/04 20:41:03	1.1.2.1
+++ include/linux/kdbprivate.h	2001/05/08 20:41:01
@@ -284,6 +284,7 @@
 	/*
 	 * General Disassembler interfaces
 	 */
+extern int kdb_dis_fprintf(PTR, const char *, ...) __attribute__ ((format (printf, 2, 3)));
 extern int kdb_dis_fprintf_dummy(PTR, const char *, ...) __attribute__ ((format (printf, 2, 3)));
 extern disassemble_info	kdb_di;
 
Index: kdb/kdb_id.c
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/kdb/Attic/kdb_id.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 kdb_id.c
--- kdb/kdb_id.c	2001/05/04 20:41:04	1.1.2.1
+++ kdb/kdb_id.c	2001/05/08 20:55:40
@@ -99,6 +99,8 @@
 	if (diag)
 		return diag;
 
+	dip->fprintf_dummy = kdb_dis_fprintf;
+
 	mode = kdbgetenv("IDMODE");
 	diag = kdba_id_parsemode(mode, dip);
 	if (diag) {
@@ -141,6 +143,9 @@
 	 * Allow the user to specify that this instruction
 	 * should be treated differently.
 	 */
+
+	kdb_di.fprintf_dummy = kdb_dis_fprintf_dummy;
+
 	mode = kdbgetenv("IDMODE");
 	diag = kdba_id_parsemode(mode, &kdb_di);
 	if (diag) {
@@ -167,10 +172,7 @@
  * 	Result of format conversion cannot exceed 255 bytes.
  */
 
-static int
-kdb_dis_fprintf(PTR file, const char *fmt, ...)
-		__attribute__ ((format (printf, 2, 3)));
-static int
+int
 kdb_dis_fprintf(PTR file, const char *fmt, ...)
 {
 	char buffer[256];
Index: kdb/kdbmain.c
===================================================================
RCS file: /trillian/src/cvs_root/linux-2.4/kdb/Attic/kdbmain.c,v
retrieving revision 1.1.2.1
diff -u -r1.1.2.1 kdbmain.c
--- kdb/kdbmain.c	2001/05/04 20:41:04	1.1.2.1
+++ kdb/kdbmain.c	2001/05/05 20:36:26
@@ -535,6 +535,17 @@
 	kdb_printf("Unknown diag %d\n", -diag);
 }
 
+/* The command history feature is not functional at the moment.  It
+ * will be replaced by something that understands editting keys,
+ * including left, right, insert, delete as well as up, down.
+ * Keith Owens, November 18 2000
+ */
+#define KDB_CMD_HISTORY_COUNT	32
+#define CMD_BUFLEN		200	/* kdb_printf: max printline size == 256 */
+static unsigned int cmd_head, cmd_tail;
+static unsigned int cmdptr;
+static char cmd_hist[KDB_CMD_HISTORY_COUNT][CMD_BUFLEN];
+
 /*
  * kdb_parse
  *
@@ -569,9 +580,10 @@
 static int
 kdb_parse(char *cmdstr, kdb_eframe_t ef)
 {
-	char *argv[MAXARGC];
-	int  argc=0;
-	char *cp;
+	static char *argv[MAXARGC];
+	static int  argc = 0;
+	static char cbuf[CMD_BUFLEN];
+	char *cp, *cpp;
 	kdbtab_t *tp;
 	int i;
 
@@ -579,22 +591,21 @@
 	 * First tokenize the command string.
 	 */
 	cp = cmdstr;
-
-	/*
-	 * If a null statement is provided, do nothing.
-	 */
-	if ((*cp == '\n') || (*cp == '\0'))
-		return 0;
 
-	while (*cp) {
-		/* skip whitespace */
-		while (isspace(*cp)) cp++;
-		if ((*cp == '\0') || (*cp == '\n'))
-			break;
-		argv[argc++] = cp;
-		/* Skip to next whitespace */
-		for(; *cp && (!isspace(*cp) && (*cp != '=')); cp++);
-		*cp++ = '\0';		/* Squash a ws or '=' character */
+	if (*cp != '\n' && *cp != '\0') {
+		argc = 0;
+		cpp = cbuf;
+		while (*cp) {
+			/* skip whitespace */
+			while (isspace(*cp)) cp++;
+			if ((*cp == '\0') || (*cp == '\n'))
+				break;
+			argv[argc++] = cpp;
+			/* Skip to next whitespace */
+			while (*cp && !isspace(*cp) && (*cp != '='))
+				*cpp++ = *cp++;
+			*cpp++ = '\0';	/* Squash a ws or '=' character */
+		}
 	}
 	if (!argc)
 		return 0;
@@ -661,17 +672,6 @@
 	}
 }
 
-/* The command history feature is not functional at the moment.  It
- * will be replaced by something that understands editting keys,
- * including left, right, insert, delete as well as up, down.
- * Keith Owens, November 18 2000
- */
-#define KDB_CMD_HISTORY_COUNT	32
-#define CMD_BUFLEN		200	/* kdb_printf: max printline size == 256 */
-static unsigned int cmd_head, cmd_tail;
-static unsigned int cmdptr;
-static char cmd_hist[KDB_CMD_HISTORY_COUNT][CMD_BUFLEN];
-
 
 static int
 handle_ctrl_cmd(char *cmd)
@@ -734,7 +734,6 @@
 	char		*cmdbuf;
 	char		cmd[CMD_BUFLEN];
 	int		diag;
-	int		parsed_once=0;  /* if false don't repeat last cmd on CR */
 	typeof (*ef)	local_ef;
 
 	if (reason != KDB_REASON_DEBUG &&
@@ -879,20 +878,14 @@
 		 * Fetch command from keyboard
 		 */
 		cmdbuf = kdb_getstr(cmdbuf, CMD_BUFLEN,"");
-		if (*cmdbuf < 32) {
-			int not_cr = *cmdbuf == '\n' ? 0 : 1;
-
-			if (!(not_cr || parsed_once)
-			   || handle_ctrl_cmd(cmdbuf)) goto do_full_getstr;
-
-			if (not_cr) goto get_again;
-		}
+		if (*cmdbuf < 32 && *cmdbuf != '\n')
+			if (handle_ctrl_cmd(cmdbuf))
+				goto do_full_getstr;
 
 		if (*cmdbuf != '\n') {
 			cmd_head = (cmd_head+1) % KDB_CMD_HISTORY_COUNT;
 			if (cmd_head == cmd_tail) cmd_tail = (cmd_tail+1) % KDB_CMD_HISTORY_COUNT;
 
-			parsed_once = 1;
 		}
 
 		cmdptr = cmd_head;

--9amGYk9869ThD9tj--

