From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 11 Sep 2002 16:55:34 +0000
Subject: [Linux-ia64] elilo-3.3 EFI assertion failure bug fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Message-Id: <marc-linux-ia64-105590701906021@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The attached patch fixes a problem with elilo-3.3 and netbooting.

The 3.3. release triggers an EFI assertion failure at least
of the HP Itanium2 machines when you type ESC or CTRL-D (i.e. abort) 
at the elilo prompt when you netboot (and only then). 
This is due to a buffer overrun.

Please apply this patch on top of elilo-3.3.

-- 
-Stephane

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo33.diff"

diff -urN elilo-3.3/ChangeLog elilo-3.3a/ChangeLog
--- elilo-3.3/ChangeLog	Mon Aug 26 16:40:08 2002
+++ elilo-3.3a/ChangeLog	Tue Sep 10 17:31:08 2002
@@ -1,3 +1,6 @@
+2002-09-10 Stephane Eranian <eranian@hpl.hp.com>
+ 	* fix a bug in argify() that was causing an EFI assertion 
+	  when aborting at the elilo prompt when netbooted.
 2002-08-26 Stephane Eranian <eranian@hpl.hp.com>
 	* fixed devschemes/simple.c to use SPrint() instead of its own buggy
 	  conversion code (spotted by Richard Hirst).
diff -urN elilo-3.3/elilo.c elilo-3.3a/elilo.c
--- elilo-3.3/elilo.c	Mon Aug 26 16:36:10 2002
+++ elilo-3.3a/elilo.c	Wed Sep 11 09:48:26 2002
@@ -239,6 +239,10 @@
  * from network. In this case, it looks like LoadOptions/LoadOptionsSize contain
  * garbage
  */
+static CHAR16 *default_load_options;
+static UINTN default_load_options_size;
+static INTN done_fixups;
+
 static VOID
 fixupargs(EFI_LOADED_IMAGE *info)
 {
@@ -250,11 +254,30 @@
 	status = BS->HandleProtocol (info->DeviceHandle, &PxeBaseCodeProtocol, (VOID **)&pxe);
 	if (EFI_ERROR(status)) return;
 
+	default_load_options      = info->LoadOptions;
+	default_load_options_size = info->LoadOptionsSize;
+
 	info->LoadOptions     = FAKE_ELILONAME;
 	info->LoadOptionsSize = StrLen(info->LoadOptions)*sizeof(CHAR16);
+
+	done_fixups = 1;
 }
 
 /*
+ * we restore the arguments in case we modified them just to make sure
+ * we don't confuse caller.
+ */
+static VOID
+unfixupargs(EFI_LOADED_IMAGE *info)
+{
+	if (done_fixups == 0) return;
+
+	info->LoadOptions     = default_load_options;
+	info->LoadOptionsSize = default_load_options_size;
+}
+
+
+/*
  * in order to get fully detailed EFI path names to devices, EDD3.0 specification must
  * be turned on. On new versions of EFI, this is the default. An environment variable
  * called EDD30 reflects the current settings. If true, then EDD3.0 is enabled 
@@ -410,8 +433,11 @@
 	 * we must copy argument because argify modifies the string.
 	 * This caused problems when arguments are coming from NVRAM
 	 * as passed by the EFI boot manager
+	 *
+	 * We add an extra character to the buffer in case the LoadOptions is not 
+	 * NULL terminated. The extra space will be used to ADD the extra terminator.
 	 */
-	arglist = alloc(info->LoadOptionsSize, EfiLoaderData);
+	arglist = alloc(info->LoadOptionsSize+sizeof(CHAR16), EfiLoaderData);
 	if (arglist == NULL) {
 		ERR_PRT((L"cannot copy argument list"));
 		return EFI_OUT_OF_RESOURCES;
@@ -603,7 +629,9 @@
 	main_loop(info->DeviceHandle, argv, argc, Optind, image);
 	/* should not return */
 do_exit:
-	if (arglist) free(arglist);
+	unfixupargs(info);
+
+	//if (arglist) free(arglist);
 
 	/* free all resources assiocated with file accesses */
 	if (devices_initialized) close_devices();

--Kj7319i9nmIyA2yE--

