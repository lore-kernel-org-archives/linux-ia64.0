From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 27 Jul 2001 21:40:17 +0000
Subject: [Linux-ia64] elilo-3.0 fix for NVRAM options
MIME-Version: 1
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Message-Id: <marc-linux-ia64-105590693005946@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I recently uncover a bug in elilo-3.0 where the argument string
(LoadOptions) is modified by the loader. Usually this is fine, as
when elilo is invoked from the EFI shell. But when elilo is invoked
directly from the EFI boot manager the command line options are
coming from NVRAM and are provided as is (no copy) to the loader. 
Because elilo split the string apart, the next invocation will see
shorten options and could potential cause problems. The fix is to 
have elilo only work on a copy of the arguments.

This patch below fixes this and is relative to elilo-3.0.


-- 

-Stephane

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=elilo-010727

--- elilo-3.0/elilo.c	Mon Jul  2 01:11:01 2001
+++ elilo-3.1/elilo.c	Fri Jul 27 14:37:10 2001
@@ -300,8 +300,7 @@
 	EFI_LOADED_IMAGE *info;
 	EFI_STATUS status, ret = EFI_LOAD_ERROR;
 	INTN argc = 0, c;
-	CHAR16 *ptr;
-	UINT8 force_prompt = 0;
+	CHAR16 *ptr, *arglist = NULL;
 	BOOLEAN devices_initialized = FALSE;
 
 	/* initialize global variable */
@@ -354,7 +353,19 @@
 	 */
 	fixupargs(info);
 
-	argc = argify(info->LoadOptions,info->LoadOptionsSize, argv); 
+	/*
+	 * we must copy argument because argify modifies the string.
+	 * This caused problems when arguments are coming from NVRAM
+	 * as passed by the EFI boot manager
+	 */
+	arglist = alloc(info->LoadOptionsSize, EfiLoaderData);
+	if (arglist == NULL) {
+		PRINT_ERR((L"cannot copy argument list"));
+		return EFI_OUT_OF_RESOURCES;
+	}
+	Memcpy(arglist, info->LoadOptions, info->LoadOptionsSize);
+
+	argc = argify(arglist,info->LoadOptionsSize, argv); 
 
 	while ((c=Getopt(argc, argv, L"pPMC:aDhd:i:vV")) != -1 ) {
 		switch(c) {
@@ -422,8 +433,6 @@
 	}
 	DBG_PRINT((L"Optind=%d optarg=%x argc=%d", Optind, Optarg, argc));
 
-	if (force_prompt) elilo_opt.prompt = 1;
-
 	/*
 	 * we can't defer this phase any longer...
 	 * Must be done after the elilo_opt are initialized (at least partially)
@@ -490,6 +499,8 @@
 	main_loop(info->DeviceHandle, argv, argc, Optind, image);
 	/* should not return */
 do_exit:
+	if (arglist) free(arglist);
+
 	/* free all resources assiocated with file accesses */
 	if (devices_initialized) close_devices();
 

--rwEMma7ioTxnRzrJ--

