From: hawkes@sgi.com
Date: Tue, 27 Jun 2006 22:01:39 +0000
Subject: [PATCH] ia64: change usermode HZ to 250
Message-Id: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, hawkes@sgi.com, Jeremy Higdon <jeremy@sgi.com>

include/asm-ia64/param.h defines HZ to be 1024 for usermode use, i.e.,
when the file gets installed as /usr/include/asm/param.h.
As the comment says:
    Technically, this is wrong, but some old apps still refer to it.  
    The proper way to get the HZ value is via sysconf(_SC_CLK_TCK).
At the very least, this technically wrong #define ought to reflect the
current default value (250) used by all arch/ia64 platforms.  No one uses
1024 anymore.  This makes those "old apps" (e.g., usr/bin/iostat) behave
properly for with a default kernel.  (And at some point, the define ought
to be removed altogether, which would expose all the applications that
erroneously expect HZ to be a compile-time constant.)

Signed-off-by: John Hawkes <hawkes@sgi.com>

Index: linux/include/asm-ia64/param.h
=================================--- linux.orig/include/asm-ia64/param.h	2006-06-17 18:49:35.000000000 -0700
+++ linux/include/asm-ia64/param.h	2006-06-27 14:46:53.119407077 -0700
@@ -36,7 +36,7 @@
     * Technically, this is wrong, but some old apps still refer to it.  The proper way to
     * get the HZ value is via sysconf(_SC_CLK_TCK).
     */
-# define HZ 1024
+# define HZ 250
 #endif
 
 #endif /* _ASM_IA64_PARAM_H */
