From: Andreas Schwab <schwab@suse.de>
Date: Fri, 13 Sep 2002 10:00:16 +0000
Subject: [Linux-ia64] Elilo-3.3: eliloalt broken
Message-Id: <marc-linux-ia64-105590701906029@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Apparently there is no single EFI variable that can be relied upon.  This
fixes eliloalt so that it just uses the first one it finds when it wants
to create the EliloAlt variable.

--- elilo-3.3/tools/eliloalt.c	2002/09/13 09:29:00	1.1
+++ elilo-3.3/tools/eliloalt.c	2002/09/13 09:39:42
@@ -41,6 +41,7 @@
 #include <errno.h>
 #include <stdint.h>
 #include <string.h>
+#include <dirent.h>
=20
=20
 #define ELILOALT_VERSION	"0.01"
@@ -49,12 +50,6 @@
 #define EFIVAR_DIR	"/proc/efi/vars"
 #define ELILO_ALTVAR	EFIVAR_DIR"/"ELILO_ALT_NAME"-00000000-0000-0000-0000-=
000000000000"
=20
-/*
- * to write/create a variable we need to open for writing ANY existing var=
iable.
- * So here we chose one that does seem to always exist
- */
-#define ELILOALT_WRITE_VICTIM EFIVAR_DIR"/Efi-47c7b226-c42a-11d2-8e57-00a0=
c969723b";
-
 #define EFI_VARIABLE_NON_VOLATILE 0x0000000000000001
 #define EFI_VARIABLE_BOOTSERVICE_ACCESS 0x0000000000000002
 #define EFI_VARIABLE_RUNTIME_ACCESS 0x0000000000000004
@@ -124,18 +119,35 @@ usage(char **argv)
 	);
 }
=20
-static void
-check_proc_efi(void)
+static char *
+check_proc_efi(int find_entry)
 {
-	int fd;
+	DIR *efi_vars;
+	struct dirent *entry;
+	static char name[1024];
=20
 	if (getuid() !=3D 0) {
 		fatal_error("This program must be run as root\n");
 	}
-	fd =3D open(EFIVAR_DIR, O_RDONLY);
-	if (fd =3D -1) {
+	efi_vars =3D opendir(EFIVAR_DIR);
+	if (efi_vars =3D NULL) {
 		fatal_error("Cannot access %s\n", EFIVAR_DIR);
 	}
+	if (!find_entry) {
+		closedir(efi_vars);
+		return NULL;
+	}
+	/* Find one entry we can open */
+	while ((entry =3D readdir(efi_vars)) !=3D NULL) {
+		if (strcmp(entry->d_name, ".") && strcmp(entry->d_name, ".."))
+			break;
+	}
+	if (entry =3D NULL) {
+		fatal_error("Cannot find entry in %s\n", EFIVAR_DIR);
+	}
+	sprintf(name, "%s/%s", EFIVAR_DIR, entry->d_name);
+	closedir(efi_vars);
+	return name;
 }
=20
 static void
@@ -144,7 +156,7 @@ delete_var(void)
 	efi_variable_t var;
 	int fd, r, i;
=20
-	check_proc_efi();
+	check_proc_efi(0);
=20
 	fd =3D open(ELILO_ALTVAR, O_WRONLY);
 	if (fd =3D -1) {
@@ -177,7 +189,7 @@ print_var(void)
 	int fd, r, i;
=20
=20
-	check_proc_efi();
+	check_proc_efi(0);
=20
 	fd =3D open(ELILO_ALTVAR, O_RDONLY);
 	if (fd =3D -1) {
@@ -203,9 +215,9 @@ set_var(char *cmdline)
 {
 	efi_variable_t var;
 	int fd, r, i, j, l;
-	char *name =3D ELILOALT_WRITE_VICTIM;
+	char *name;
=20
-	check_proc_efi();
+	name =3D check_proc_efi(1);
=20
 	if (cmdline =3D NULL) {
 		fatal_error("invalid cmdline argument\n");

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

