From: Andreas Schwab <schwab@suse.de>
Date: Tue, 05 Sep 2000 13:32:13 +0000
Subject: Re: [Linux-ia64] [PATCH] various eli patches
Message-Id: <marc-linux-ia64-105590678205451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Bill Nottingham <notting@redhat.com> writes:

|> These are against CVS of a couple of weeks ago.
|>=20
|> - eli-initrd-fix.patch:  fixes initrd support, and a couple of compilati=
on
|>   tweaks. virt_to_phys() on an already physical address doesn't yeild a
|>   working initrd location.

IMHO it is better to change read_file to expect a physical address for the
buffer, since this is all it uses anyway.  That way there is no need to
convert from physical address to virtual address and back again.

Here is the patch to implement this:

--- eli.c~	Thu Aug 17 11:18:39 2000
+++ eli.c	Thu Aug 17 11:27:08 2000
@@ -370,7 +370,7 @@
 }
=20
 static EFI_STATUS read_file(EFI_FILE_HANDLE fs, EFI_FILE_HANDLE file,
-		UINT64 vbuffer, UINT64 total_size)
+		EFI_PHYSICAL_ADDRESS buffer, UINT64 total_size)
 {
 	EFI_STATUS status;
=20
@@ -383,10 +383,8 @@
 	 * needed.
 	 */
 	{
-		EFI_PHYSICAL_ADDRESS buffer;
 		UINTN j =3D 0;
=20
-		buffer =3D virt_to_phys(vbuffer);
 		while (total_size > 0) {
 			CHAR8 helicopter[4] =3D { '|' , '/' , '-' , '\\' };
 			UINT64 size;
@@ -411,7 +409,7 @@
 	}
 #else=09
 	size =3D total_size;
-	status =3D fs->Read(file, &size, (VOID *) virt_to_phys(start_addr));
+	status =3D fs->Read(file, &size, (VOID *) buffer);
 	if (EFI_ERROR(status))
 		return EFI_LOAD_ERROR;
=20
@@ -422,7 +420,7 @@
 }
=20
 static INTN load_ramdisk(EFI_FILE_HANDLE fs, CHAR16 *filename,
-		UINT64 start_addr, struct allocated_memory *memory)
+		EFI_PHYSICAL_ADDRESS start_addr, struct allocated_memory *memory)
 {
 	EFI_FILE_HANDLE file;
 	EFI_STATUS status;
@@ -613,7 +611,7 @@
 	    		return EFI_LOAD_ERROR;
 		}
=20
-		status =3D read_file(fs, file, phdr.p_vaddr, phdr.p_filesz);
+		status =3D read_file(fs, file, virt_to_phys(phdr.p_vaddr), phdr.p_filesz=
);
 		if (EFI_ERROR(status)) {
 			Print(W2U(L"%s: read failed: %r\n"), filename, status);
 			BS->FreePages(min_addr, pages);
@@ -1263,6 +1261,9 @@
 		case EFI_LOAD_ERROR:
 			goto free_kernel_image;
 		}
+	} else {
+		initrd.start_addr =3D 0;
+		initrd.pages =3D 0;
 	}
=20
 	/* Must free the ACPI before creating the boot params so the */

Andreas.

--=20
Andreas Schwab                                  "And now for something
SuSE Labs                                        completely different."
Andreas.Schwab@suse.de
SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg

