From: Bill Nottingham <notting@redhat.com>
Date: Fri, 26 May 2000 15:32:01 +0000
Subject: Re: [Linux-ia64] Linux IA-64 yacc error
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Message-Id: <marc-linux-ia64-105590678205110@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205109@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205109@msgid-missing>
To: linux-ia64@vger.kernel.org

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii

Greg Harris (gregh@unify.com) said: 
> > yacc makey.y
> > 
> > yacc:f - out of space.

yacc is broken. Try the attached patch.

Bill

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="byacc-fix.patch"

--- byacc-1.9/defs.h.busted	Sat May  6 21:10:56 2000
+++ byacc-1.9/defs.h	Sat May  6 21:11:22 2000
@@ -1,7 +1,8 @@
 #include <assert.h>
 #include <ctype.h>
 #include <stdio.h>
-
+#include <string.h>
+#include <stdlib.h>
 
 /*  machine-dependent definitions			*/
 /*  the following definitions are for the Tahoe		*/
@@ -280,10 +281,3 @@
 extern int errno;
 
 
-/* system functions */
-
-extern void free();
-extern char *calloc();
-extern char *malloc();
-extern char *realloc();
-extern char *strcpy();

--IS0zKkzwUGydFO0o--


