From: Bill Nottingham <notting@redhat.com>
Date: Fri, 20 Apr 2001 23:14:49 +0000
Subject: [Linux-ia64] Re: New gnu-efi package and new boot loader available
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
Message-Id: <marc-linux-ia64-105590693005448@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Stephane Eranian (eranian@frankl.hpl.hp.com) said: 
> This version of the gnu-efi package includes a new version of the boot loader
> which represents the merge of ELI and LILO into ELILO. 
> Most features of each have been merged. This means that ELI's config 
> file (a la LILO/ia-32) is supported, for instance.
> 
> Support and development on the bootloader will now focus on this new version.

A few ELILO patches - one bugfix:
- elilo-makefile.patch
  Tweaks the dependency rules in the Makefile so it will rebuild OK if
  you change one file.
  
one behavior change:
- elilo-image.patch
  Appends extra command-line parameters to any image parameters, instead
  of overriding all of them. Overriding things like 'ro' or 'root='
  should still work, AFAIK.
  
and two things catering to my personal preferences :) :
- elilo-query.patch
  Makes the '-q' behavior the default, and adds a '-Q' to turn on querying.
- elilo-verbosity.patch
  Wraps many messages with 'if (elilo_opt.verbose)'; also
  turns off the timeout if an image was specified on the command line

Comments? 

Bill

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-makefile.patch"

diff -ru gnu-efi-2.0-old/Make.rules gnu-efi-2.0/Make.rules
--- gnu-efi-2.0-old/Make.rules	Wed Apr  4 12:56:42 2001
+++ gnu-efi-2.0/Make.rules	Wed Apr 18 16:17:08 2001
@@ -4,3 +4,6 @@
 
 %.so: %.o
 	$(LD) $(LDFLAGS) $^ -o $@ $(LOADLIBES)
+
+%.o: %.c
+	$(CC) $(CFLAGS) $(CPPFLAGS) -c $^ -o $@
diff -ru gnu-efi-2.0-old/elilo/Makefile gnu-efi-2.0/elilo/Makefile
--- gnu-efi-2.0-old/elilo/Makefile	Thu Apr  5 02:03:22 2001
+++ gnu-efi-2.0/elilo/Makefile	Wed Apr 18 16:18:45 2001
@@ -36,11 +36,15 @@
 
 all:	$(TARGETS)
 
+elilo.efi: elilo.so
+
 elilo.so: getopt.o strchr.o loader.o gzip_loader.o gzip.o  \
          plain_loader.o localfs.o netfs.o fileops.o util.o alloc.o fpswa.o \
 	 memset.o memcpy.o config.o initrd.o alternate.o
 
-gzip.o : inflate.c
+gzip.o: gzip.c inflate.c
+	$(CC) $(CFLAGS) $(CPPFLAGS) -c gzip.c -o $@
+
 
 clean:
 	rm -f $(TARGETS) *~ *.o *.so

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-image.patch"

--- gnu-efi-2.0/elilo/elilo.c.verbosity	Fri Apr 20 18:33:42 2001
+++ gnu-efi-2.0/elilo/elilo.c	Fri Apr 20 19:12:55 2001
@@ -367,7 +370,7 @@
 	 * config file 
 	 */
 	if (argc > 1+index) {
-		StrCpy(args, argv[++index]);
+		/* StrCpy(args, argv[++index]); */
 		while (++index < argc) {
 			StrCat(args, W2U(L" "));
 			StrCat(args, argv[index]);

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-query.patch"

--- gnu-efi-2.0/elilo/elilo.c.ook	Wed Apr 18 22:53:04 2001
+++ gnu-efi-2.0/elilo/elilo.c	Wed Apr 18 22:54:23 2001
@@ -71,7 +71,9 @@
 	UINTN initrd_size;		/* how big is the initial ramdisk */
 };
 
-elilo_opt_t elilo_opt;
+elilo_opt_t elilo_opt = {
+	noquery: 1
+};
 
 EFI_SYSTEM_TABLE *systab;
 
@@ -622,13 +622,16 @@
 
 	argc = argify(info->LoadOptions,info->LoadOptionsSize, argv); 
 
-	while ((c=Getopt(argc, argv, W2U(L"C:adqht:i:vVf"))) != -1 ) {
+	while ((c=Getopt(argc, argv, W2U(L"C:adQqht:i:vVf"))) != -1 ) {
 		switch(c) {
 			case 'a':
 				elilo_opt.always_alt=1;
 				break;
 			case 'd':
 				elilo_opt.debug=1;
+				break;
+			case 'Q':
+				elilo_opt.noquery=0;
 				break;
 			case 'q':
 				elilo_opt.noquery=1;
--- gnu-efi-2.0/elilo/elilo.txt.ook	Wed Apr 18 22:54:30 2001
+++ gnu-efi-2.0/elilo/elilo.txt	Wed Apr 18 22:55:21 2001
@@ -37,10 +37,13 @@
 	-v	Turn on verbose mode. LILO prints more message about what it 
 		is doing.
 
-	-q	Do not ask for a keypress when invoked in interactive mode. 
+	-Q	Ask for a keypress when invoked in interactive mode. 
 		The interactive mode is entered when LILO is invoked with 
 		command line arguments or when it is interrupted in the middle
-		of loading an image. 
+		of loading an image.
+
+	-q	Do not ask for a keypress when invoked in interactive mode. 
+		(This option is the default.)
 
 	-a	Always check for alternate kernel image. When LILO detects that
 		it has been invoked with some command line argument, the 

--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-verbosity.patch"

--- gnu-efi-2.0/elilo/elilo.c.verbosity	Fri Apr 20 18:33:42 2001
+++ gnu-efi-2.0/elilo/elilo.c	Fri Apr 20 19:12:55 2001
@@ -99,7 +99,8 @@
 		return ELILO_BOOT_ERROR;
 
 	}
-	Print(W2U(L"Using %a loader\r\n"), ldops->ld_name);
+	if (elilo_opt.verbose)
+		Print(W2U(L"Using %a loader\r\n"), ldops->ld_name);
 	
 	ret = ldops->ld_load_kernel(dev, fops, kname, kentry, kend);
 
@@ -313,6 +314,7 @@
 	static CHAR16 initrd_name[CMDLINE_MAXLEN];
 	static CHAR16 args[CMDLINE_MAXLEN];
 	static CHAR16 final_args[CMDLINE_MAXLEN];
+	static INTN first=0;
 
 	CHAR16 *ptr;
 	EFI_STATUS status;
@@ -389,12 +392,22 @@
 		split_args(buffer, &kname, &args);
 #endif
 
-	Print(W2U(L"kernel     is  '%s'\r\n"), kname);
-	Print(W2U(L"arguments  are '%s'\r\n"), args);
+	if (elilo_opt.verbose) {
+		Print(W2U(L"kernel     is  '%s'\r\n"), kname);
+		Print(W2U(L"arguments  are '%s'\r\n"), args);
 
-	if (elilo_opt.initrd_file) Print(W2U(L"initrd      is '%s'\r\n"), elilo_opt.initrd_file);
+		if (elilo_opt.initrd_file)
+			Print(W2U(L"initrd      is '%s'\r\n"), elilo_opt.initrd_file);
+	}
+	
+	if (!first) {
+		if (!elilo_opt.verbose)
+			Print(W2U(L"ELILO"));
+		first++;
+	}
 
-	bootmode = waitkey_timeout(elilo_opt.timeout, buffer);
+	if (!argv[index]) 
+		bootmode = waitkey_timeout(elilo_opt.timeout, buffer);
 	switch(bootmode) {
 		case ELILO_BOOT_ABORTED:
 			return ELILO_BOOT_ABORTED;
@@ -403,7 +416,7 @@
 			if (select_kernel(buffer, sizeof(buffer)) == ELILO_BOOT_ERROR)
 				return EFI_LOAD_ERROR;
 
-Print(W2U(L"buffer is '%s'\r\n"), buffer);
+			DBG_PRINT((W2U(L"buffer is '%s'\r\n"), buffer));
 
 			//split_args(buffer, kname, args);	
 
@@ -416,13 +429,15 @@
 		case ELILO_BOOT_AUTO: 
 		case ELILO_BOOT_DEFAULT:
 			/* nothing to do here */
+			Print(W2U(L"\r\n"));
 			break;
 		default:
 			Print(W2U(L"unkown bootmode\r\n"));
 			return ELILO_BOOT_ERROR;
 	}
 retry_default:
-	Print(W2U(L"Booting '%s' with args='%s'\r\n"), kname, args);
+	if (elilo_opt.verbose)
+		Print(W2U(L"Booting '%s' with args='%s'\r\n"), kname, args);
 
 	/*
 	 * Now let's try to load the kernel !
@@ -449,8 +464,10 @@
 			goto retry_default;
 		
 		case ELILO_BOOT_ABORTED:
-			Print(W2U(L"Kernel    : '%s'\r\n"), kname);
-			Print(W2U(L"Arguments : '%s'\r\n"), args);
+			if (elilo_opt.verbose) {
+				Print(W2U(L"Kernel    : '%s'\r\n"), kname);
+				Print(W2U(L"Arguments : '%s'\r\n"), args);
+			}
 			/* we drop initrd in case we aborted the load */
 			elilo_opt.initrd_file = NULL;
 			goto retry_interactive;
@@ -488,8 +505,10 @@
 				 */
 				free_kmem();
 
-				Print(W2U(L"kernel     is  '%s'\r\n"), kname);
-				Print(W2U(L"arguments  are '%s'\r\n"), args);
+				if (elilo_opt.verbose) {
+					Print(W2U(L"kernel     is  '%s'\r\n"), kname);
+					Print(W2U(L"arguments  are '%s'\r\n"), args);
+				}
 
 				goto retry_interactive;
 		}
@@ -500,7 +519,9 @@
 	/*
 	 * Do we want to wait for keypress here ?
 	 */
-	Print(W2U(L"Starting kernel at 0x%lx\r\n"), kentry);
+	if (elilo_opt.verbose) {
+		Print(W2U(L"Starting kernel at 0x%lx\r\n"), kentry);
+	}
 
 	if (bootmode != ELILO_BOOT_AUTO && elilo_opt.noquery==0) {
 		if(wait_keypress_abort() != ELILO_BOOT_SUCCESS) goto exit_error;
@@ -658,7 +679,8 @@
 		return EFI_LOAD_ERROR;
 	}
 
-	Print(W2U(L"Using %a access\r\n"), fops->fops_name);
+	if (elilo_opt.verbose)
+		Print(W2U(L"Using %a access\r\n"), fops->fops_name);
 
 	main_loop(info->DeviceHandle, fops, argv, argc, Optind, image);
 	/* should not return */
--- gnu-efi-2.0/elilo/plain_loader.c.verbosity	Thu Apr  5 15:37:54 2001
+++ gnu-efi-2.0/elilo/plain_loader.c	Fri Apr 20 18:33:42 2001
@@ -101,7 +101,7 @@
 }
 
 static INTN
-load_elf(INTN fd, fileops_t *fops, VOID *kentry, VOID *kend)
+load_elf(INTN fd, fileops_t *fops, VOID *kentry, VOID *kend, CHAR16 *kname)
 {
 	Elf64_Ehdr ehdr;
 	Elf64_Phdr *phdrs;
@@ -226,8 +226,10 @@
 	 * virtual address where the kernel code starts
 	 */
 
-    	Print(W2U(L"Press any key to interrupt\r\n"));
-    	Print(W2U(L"Loading kernel.."));
+	if (elilo_opt.verbose) {
+    		Print(W2U(L"Press any key to interrupt\r\n"));
+	}
+	Print(W2U(L"Loading %s..."), kname);
 	
 	/* Second pass:
 	 * Walk through the program headers
@@ -311,7 +313,7 @@
 	status = fops->fops_open(dev, kname, &fd);
 	if (EFI_ERROR(status)) return ELILO_BOOT_ERROR;
 
-	ret = load_elf(fd, fops, kentry, kend);
+	ret = load_elf(fd, fops, kentry, kend, kname);
 
 	fops->fops_close(fd);
 
--- gnu-efi-2.0/elilo/util.c.verbosity	Thu Apr  5 13:46:18 2001
+++ gnu-efi-2.0/elilo/util.c	Fri Apr 20 18:33:42 2001
@@ -96,14 +96,16 @@
 		return ELILO_BOOT_ABORTED;
 	}
 	
-	Print(W2U(L"Press ENTER to continue or ANY other key to cancel\r\n"));
+	if (elilo_opt.verbose)
+		Print(W2U(L"Press ENTER to continue or ANY other key to cancel\r\n"));
 
 	list[0] = timer;
 	list[1] = systab->ConIn->WaitForKey;
 
 	do {
 
-		Print(W2U(L"%s autoboot in %-3d seconds\r"), kernel_name, timeout);
+		if (elilo_opt.verbose)
+			Print(W2U(L"%s autoboot in %-3d seconds\r"), kernel_name, timeout);
 		status = BS->WaitForEvent(2, list, &idx);
 		if (EFI_ERROR(status)) {
 			PRINT_ERR((W2U(L"waitkey WaitForEvent failed %r"), status));

--Q68bSM7Ycu6FN28Q--

