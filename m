From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Sun, 15 Apr 2001 03:47:47 +0000
Subject: [Linux-ia64] Linuxconf patch
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Message-Id: <marc-linux-ia64-105590693005401@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi there!!

Here is a patch to make linuxconf work on ia64.

Btw, should I send patches like this to the list, or I'm just filling
up your mailboxes?

I'd also like to introduce myself, since I haven't had time to do
so before. I've been working in the last two weeks to port
Conectiva Linux to ia64. If you know about any way I can help you,
or just want to exchange ideas (well, maybe this list is the best
place to do this), please, let me know.

Thanks!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linuxconf-1.25-ia64.patch"

diff -u -r linuxconf-1.25/askrunlevel/boot.cc linuxconf-1.25.ia64/askrunlevel/boot.cc
--- linuxconf-1.25/askrunlevel/boot.cc	Thu Apr 12 23:16:04 2001
+++ linuxconf-1.25.ia64/askrunlevel/boot.cc	Wed Apr 11 21:45:52 2001
@@ -5,6 +5,7 @@
 #include <fcntl.h>
 #include <sys/types.h>
 #include <time.h>
+#include <sys/time.h>
 #include "askrunlevel.h"
 #include <misc.h>
 #include "../paths.h"
diff -u -r linuxconf-1.25/fstab/quota.cc linuxconf-1.25.ia64/fstab/quota.cc
--- linuxconf-1.25/fstab/quota.cc	Thu Nov  2 02:32:58 2000
+++ linuxconf-1.25.ia64/fstab/quota.cc	Thu Apr 12 12:03:21 2001
@@ -366,6 +366,18 @@
 	{
 		return syscall(__NR_quotactl, cmd, special, id, addr);
 	}
+#elif defined(__ia64__)
+	#include <asm/unistd.h>
+	int quotactl(int cmd, const char * special, int id, caddr_t addr)
+	{
+		register long r8 asm ("r8");
+		asm volatile ("mov r15=%1\n\t"
+			      "break %2"
+			      : "=r"(r8)
+			      : "g"(__NR_quotactl), "g"(__BREAK_SYSCALL),
+				"r"(cmd), "r"(special), "r"(id), "r"(addr));
+		return r8;
+	}
 #else
 	#define __LIBRARY__
 	#include <linux/unistd.h>
diff -u -r linuxconf-1.25/help.files/es/drbdconf/Makefile linuxconf-1.25.ia64/help.files/es/drbdconf/Makefile
--- linuxconf-1.25/help.files/es/drbdconf/Makefile	Mon Jan 22 02:13:35 2001
+++ linuxconf-1.25.ia64/help.files/es/drbdconf/Makefile	Thu Apr 12 18:34:59 2001
@@ -1,12 +1 @@
-CURDIR=drbdconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/es/heartbeatconf/Makefile linuxconf-1.25.ia64/help.files/es/heartbeatconf/Makefile
--- linuxconf-1.25/help.files/es/heartbeatconf/Makefile	Mon Jan 22 02:17:09 2001
+++ linuxconf-1.25.ia64/help.files/es/heartbeatconf/Makefile	Thu Apr 12 18:35:27 2001
@@ -1,12 +1 @@
-CURDIR=heartbeatconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/es/pslaveconf/Makefile linuxconf-1.25.ia64/help.files/es/pslaveconf/Makefile
--- linuxconf-1.25/help.files/es/pslaveconf/Makefile	Mon Jan 22 02:15:56 2001
+++ linuxconf-1.25.ia64/help.files/es/pslaveconf/Makefile	Thu Apr 12 18:35:42 2001
@@ -1,12 +1 @@
-CURDIR=pslaveconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/pt/drbdconf/Makefile linuxconf-1.25.ia64/help.files/pt/drbdconf/Makefile
--- linuxconf-1.25/help.files/pt/drbdconf/Makefile	Mon Jan 22 02:13:35 2001
+++ linuxconf-1.25.ia64/help.files/pt/drbdconf/Makefile	Thu Apr 12 18:34:59 2001
@@ -1,12 +1 @@
-CURDIR=drbdconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/pt/heartbeatconf/Makefile linuxconf-1.25.ia64/help.files/pt/heartbeatconf/Makefile
--- linuxconf-1.25/help.files/pt/heartbeatconf/Makefile	Mon Jan 22 02:17:09 2001
+++ linuxconf-1.25.ia64/help.files/pt/heartbeatconf/Makefile	Thu Apr 12 18:35:27 2001
@@ -1,12 +1 @@
-CURDIR=heartbeatconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/pt/pslaveconf/Makefile linuxconf-1.25.ia64/help.files/pt/pslaveconf/Makefile
--- linuxconf-1.25/help.files/pt/pslaveconf/Makefile	Mon Jan 22 02:15:56 2001
+++ linuxconf-1.25.ia64/help.files/pt/pslaveconf/Makefile	Thu Apr 12 18:35:42 2001
@@ -1,12 +1 @@
-CURDIR=pslaveconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/sources/drbdconf/Makefile linuxconf-1.25.ia64/help.files/sources/drbdconf/Makefile
--- linuxconf-1.25/help.files/sources/drbdconf/Makefile	Mon Jan 22 02:13:35 2001
+++ linuxconf-1.25.ia64/help.files/sources/drbdconf/Makefile	Thu Apr 12 18:34:59 2001
@@ -1,12 +1 @@
-CURDIR=drbdconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/sources/heartbeatconf/Makefile linuxconf-1.25.ia64/help.files/sources/heartbeatconf/Makefile
--- linuxconf-1.25/help.files/sources/heartbeatconf/Makefile	Mon Jan 22 02:17:09 2001
+++ linuxconf-1.25.ia64/help.files/sources/heartbeatconf/Makefile	Thu Apr 12 18:35:27 2001
@@ -1,12 +1 @@
-CURDIR=heartbeatconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/help.files/sources/pslaveconf/Makefile linuxconf-1.25.ia64/help.files/sources/pslaveconf/Makefile
--- linuxconf-1.25/help.files/sources/pslaveconf/Makefile	Mon Jan 22 02:15:56 2001
+++ linuxconf-1.25.ia64/help.files/sources/pslaveconf/Makefile	Thu Apr 12 18:35:42 2001
@@ -1,12 +1 @@
-CURDIR=pslaveconf
-all: doc
-DOCS := $(shell cat FILE_LIST)
-
-include /usr/lib/linuxconf-devel/rules.mak
-
-doc:
-	@/usr/lib/linuxconf-devel/sgml_2_help.sh $(DOCS)
-
-install:
-	@/usr/lib/linuxconf-devel/install_helps.sh $(CURDIR) $(LIB_LINUXCONF)
-
+include ../../scripts/help.mak
diff -u -r linuxconf-1.25/libmodules/parsers/isc.cc linuxconf-1.25.ia64/libmodules/parsers/isc.cc
--- linuxconf-1.25/libmodules/parsers/isc.cc	Sat Dec 30 15:19:04 2000
+++ linuxconf-1.25.ia64/libmodules/parsers/isc.cc	Thu Apr 12 23:17:51 2001
@@ -66,7 +66,7 @@
 	if (pt != NULL){
 		char *start = tmp;
 		while (start < pt){
-			if (!isspace(start)) break;
+			if (!isspace(*start)) break;
 			start++;
 		}
 		if (start == pt){
diff -u -r linuxconf-1.25/main/linuxconf.cc linuxconf-1.25.ia64/main/linuxconf.cc
--- linuxconf-1.25/main/linuxconf.cc	Thu Feb  8 18:53:35 2001
+++ linuxconf-1.25.ia64/main/linuxconf.cc	Wed Apr 11 22:22:22 2001
@@ -256,6 +256,8 @@
 	    { "Motorola", "mvme" },
 	    { NULL, NULL }
 	};
+#elif defined(__ia64__)
+	static const char keymap_arch[]="ia64";
 #else
 	#error Need a ifdef for your architecture here
 #endif
diff -u -r linuxconf-1.25/modules/Xkbdconf/XFconfig.c linuxconf-1.25.ia64/modules/Xkbdconf/XFconfig.c
--- linuxconf-1.25/modules/Xkbdconf/XFconfig.c	Fri Dec 29 16:54:26 2000
+++ linuxconf-1.25.ia64/modules/Xkbdconf/XFconfig.c	Thu Apr 12 17:20:42 2001
@@ -3,6 +3,7 @@
 #include <stdio.h>
 #include <stdarg.h>
 #include <string.h>
+#include <stdlib.h>
 #include <X11/Xlib.h>
 #include <X11/XKBlib.h>
 #include <X11/extensions/XKBgeom.h>
diff -u -r linuxconf-1.25/modules/mouseconf/mousedetect.c linuxconf-1.25.ia64/modules/mouseconf/mousedetect.c
--- linuxconf-1.25/modules/mouseconf/mousedetect.c	Wed Nov 29 02:15:43 2000
+++ linuxconf-1.25.ia64/modules/mouseconf/mousedetect.c	Thu Apr 12 17:22:17 2001
@@ -13,6 +13,7 @@
 #include <locale.h>
 #include <libgen.h>
 */
+#include <string.h>
 
 #include <kudzu.h>
 
diff -u -r linuxconf-1.25/rules.mak linuxconf-1.25.ia64/rules.mak
--- linuxconf-1.25/rules.mak	Mon Mar 12 02:43:48 2001
+++ linuxconf-1.25.ia64/rules.mak	Thu Apr 12 12:27:36 2001
@@ -55,7 +55,7 @@
 WWWBASE=$(HOME)/n/dnshtml
 WWWTECHBASE=$(WWWBASE)/linuxconf/tech
 SPEC_FILE = $(shell $(GCC) -v 2>&1 | head -1 | sed 's/^.* //')
-LD_LINUX = $(notdir $(shell cat $(SPEC_FILE) | sed -n -e '/:-dynamic-linker/s/^.*:-dynamic-linker \([^}]*\).*/\1/p'))
+LD_LINUX = $(patsubst ld-linux%.so.2,ld-linux.so.2,$(notdir $(shell cat $(SPEC_FILE) | sed -n -e '/:-dynamic-linker/s/^.*:-dynamic-linker \([^}]*\).*/\1/p')))
 ifeq ($(LD_LINUX),ld-linux.so.2)
 CRYPTLIB=-lcrypt
 PAMLIB=-lpam
--- linuxconf-1.25/modules/mouseconf/XFmousereset.c	Mon Dec 18 14:26:13 2000
+++ linuxconf-1.25.ia64/modules/mouseconf/XFmousereset.c	Fri Apr 13 12:16:22 2001
@@ -11,5 +11,5 @@
 
-// #include <stdlib.h>
+#include <stdlib.h>
 #include <stdio.h>
-// #include <string.h>
+#include <string.h>
 #include <X11/Xlib.h>

--ZGiS0Q5IWpPtfppv--

