From: Keith Owens <kaos@sgi.com>
Date: Mon, 04 Oct 2004 06:25:58 +0000
Subject: [patch 4/5 salinfo-0.6] output
Message-Id: <11379.1096871158@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

output          Stop stdout and stderr stamping on each other

Index: salinfo-0.6/salinfo_decode.c
=================================--- salinfo-0.6.orig/salinfo_decode.c	Mon Oct  4 13:20:11 2004
+++ salinfo-0.6/salinfo_decode.c	Mon Oct  4 13:22:07 2004
@@ -304,12 +304,12 @@ talk_to_sal (const char *type, const cha
 			type,
 			suffix);
 		fclose(stdout);
-		if (!(stdout = fopen(filename, "w"))) {
+		if (!(stdout = fopen(filename, "a"))) {
 			perror(filename);
 			goto out;
 		}
 		fclose(stderr);
-		if (!((stderr = fopen(filename, "w")))) {
+		if (!((stderr = fopen(filename, "a")))) {
 			perror(filename);
 			goto out;
 		}

