From: Bill Nottingham <notting@redhat.com>
Date: Tue, 29 Aug 2000 20:19:21 +0000
Subject: [Linux-ia64] [PATCH] various eli patches
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Message-Id: <marc-linux-ia64-105590678205415@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

These are against CVS of a couple of weeks ago.

- eli-initrd-fix.patch:  fixes initrd support, and a couple of compilation
  tweaks. virt_to_phys() on an already physical address doesn't yeild a
  working initrd location.
- eli-imagename.patch: allows passing of image names on the command
  line along with command line parameters; similarly, allows for
  passing of command line parmaters to images in the image selection
  prompt.  This breaks image names with spaces, if anyone was using
  them.
  
Bill

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eli-initrd-fix.patch"

diff -ru eli.old/eli.c eli/eli.c
--- eli.old/eli.c	Fri Aug 18 16:21:55 2000
+++ eli/eli.c	Fri Aug 18 16:24:58 2000
@@ -39,6 +39,7 @@
 #define ROUNDUP(x,a)	(((x) + (a) - 1) & ~((a) - 1))
 
 #define virt_to_phys(a) ((EFI_PHYSICAL_ADDRESS) ((UINT64) (a) - 0xe000000000000000ULL))
+#define phys_to_virt(a) ((EFI_PHYSICAL_ADDRESS) ((UINT64) (a) + 0xe000000000000000ULL))
 
 /* This is the structure passed to the kernel */
 struct ia64_boot_param {
@@ -112,7 +113,7 @@
 	CHAR16 *last = optionstr + optionsize/2;
 
 #ifdef DEBUG
-	Print(W2U(L"split_command_line: size %d, '%s'\n", optionsize, optionstr));
+	Print(W2U(L"split_command_line: size %d, '%s'\n"), optionsize, optionstr);
 #endif
 
 	do {
@@ -411,7 +412,7 @@
 	}
 #else	
 	size = total_size;
-	status = fs->Read(file, &size, (VOID *) virt_to_phys(start_addr));
+	status = fs->Read(file, &size, (VOID *) virt_to_phys(vbuffer));
 	if (EFI_ERROR(status))
 		return EFI_LOAD_ERROR;
 
@@ -455,9 +456,9 @@
         status = BS->AllocatePages(AllocateAddress, EfiLoaderCode, pages, &start_addr);
 	if (EFI_ERROR(status))
 		return EFI_LOAD_ERROR;
-
+	
 	/* Make Buffer point to the requested physical address in memory */
-	status = read_file(fs, file, start_addr, total_size);
+	status = read_file(fs, file, phys_to_virt(start_addr), total_size);
 	if (EFI_ERROR(status)) {
 		Print(W2U(L"%s: read failed: %r\n"), filename, status);
 		BS->FreePages(start_addr, pages);

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eli-imagename.patch"

--- eli/eli.c.imagename	Fri Aug 18 16:35:38 2000
+++ eli/eli.c	Fri Aug 18 19:20:04 2000
@@ -69,7 +70,7 @@
 	UINT64 initrd_size;
 };
 
-#define MAX_IMAGE_NAME	15
+#define MAX_IMAGE_NAME	1024
 
 struct boot_image {
 	struct boot_image *next;
@@ -989,7 +990,7 @@
 				Print(W2U(L"\n"));
 
 				for (timage = image_head; timage; timage = timage->next) {
-					Print(W2U(L"%-*s "), MAX_IMAGE_NAME, timage->label);
+					Print(W2U(L"%s "), timage->label);
 					if ((i % 3) == 2)
 						Print(W2U(L"\n"));
 					i++;
@@ -1014,14 +1015,14 @@
 			case CHAR_CARRIAGE_RETURN:
 			{
 				struct boot_image *timage;
-
+				int x;
+				
 				if (!imagename[0]) {
 					Print(W2U(L"\n"));
 
 					return default_image;
 				}
-
-
+				
 				/* Attempt to find the image name now */
 				for (timage = image_head; timage; timage = timage->next) {
 					if (StriCmp(timage->label, imagename) == 0) {
@@ -1031,6 +1032,24 @@
 					}
 				}
 
+				/* Perhaps they added some arguments? */
+				for (x = 0; imagename[x] && x < MAX_IMAGE_NAME; x++) {
+					if (imagename[x] == L' ') {
+						imagename[x] = 0;
+						for (timage = image_head; timage; timage = timage->next) {
+							if (StriCmp(timage->label, imagename) == 0) {
+								
+								StrCat(args, W2U(L" "));
+								StrCat(args,imagename+x+1);
+								Print(W2U(L"\n"));       
+								return timage;
+							}
+						}
+						imagename[x] = L' ';
+						break;
+					}
+				}
+
 				Print(W2U(L"\n\nUnknown image %s\n\nboot: "),
 					imagename);
 
@@ -1095,7 +1113,7 @@
 	struct allocated_memory kernel, initrd, new_systab;
 	UINTN argc;
 	CHAR16 *argv[MAX_ARGS];
-	struct boot_image *boot_image = NULL;
+	struct boot_image *boot_image = NULL, *tmp_image;
 	struct acpi_op *acpi_root = NULL;
 	UINTN cookie;
         struct vector *vectors;
@@ -1169,15 +1187,24 @@
 		if (boot_image)
 			StrCpy(kernel_name, boot_image->filename);
 	}
+	
+	/* If they passed us an image name, use that instead */
+	if (!boot_image)
+		for (tmp_image = image_head; tmp_image; tmp_image = tmp_image->next) {
+			if (StriCmp(tmp_image->label, kernel_name) == 0) {
+				boot_image = tmp_image;
+				StrCpy(kernel_name, boot_image->filename);
+			}
+		}
 
 	if (!kernel_name[0]) {
 		Print(W2U(L"eli: no kernel to boot!\n"));
 		goto free_acpi;
 	}
-
+	
 	/* Setup the arguments to the kernel from the info on the command */
 	/* line and configuration file */
-	if (!args[0]) {
+	if (!args[0] || boot_image) {
 		INT8 ro = -1;
 
 		if (boot_image && boot_image->root) {

--ew6BAiZeqk4r7MaW--

