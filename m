From: "Jim Hull" <jim.hull@hp.com>
Date: Fri, 31 Jan 2003 20:10:29 +0000
Subject: RE: [Linux-ia64] Script for decoding PSR in oopses
Message-Id: <marc-linux-ia64-105590709805791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter wrote:

> BTW, there's a bug in the AWK script:

There's also a bug in perl version of ia64_psr:
--- ia64_psr_orig	Fri Jan 31 11:49:35 2003
+++ ia64_psr	Fri Jan 31 11:49:35 2003
@@ -11,7 +11,7 @@
 	[ 4, 1, "mfl" ],
 	[ 5, 1, "mfh" ],
 	[ 0, 24, "System mask" ],
-	[ 6, 6, "rv" ],
+	[ 6, 7, "rv" ],
 	[ 13, 1, "ic" ],
 	[ 14, 1, "i" ],
 	[ 15, 1, "pk" ],

 -- Jim


