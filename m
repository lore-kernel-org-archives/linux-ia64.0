From: Andrew Morton <akpm@osdl.org>
Date: Tue, 02 Nov 2004 22:18:30 +0000
Subject: Re: [PATCH] IA64 build broken... cond_syscall()... Fixes?
Message-Id: <20041102141830.5958d188.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02510E27@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F02510E27@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: peterc@gelato.unsw.edu.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> wrote:
>
> 
> >Andrew> Shouldn't we just bite the bullet and hoist all that
> >Andrew> cond_syscall stuff out into its own .c file?
> >
> >OK.  Patch appended.
> >
> >Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>
> >
> 
> Acked-by: Tony Luck
> 
> No surprise that Peter's fix works for me since I'm building
> ia64 systems too.

yup.  It needed a fixlet for other platforms.  I'll scoot it along to Linus
today.

--- 25/kernel/sys_ni.c~sys_ni-fix	2004-11-01 23:17:15.324673272 -0800
+++ 25-akpm/kernel/sys_ni.c	2004-11-01 23:17:36.497454520 -0800
@@ -1,6 +1,9 @@
-#include <asm/unistd.h>
+
+#include <linux/linkage.h>
 #include <linux/errno.h>
 
+#include <asm/unistd.h>
+
 /*
  * Non-implemented system calls get redirected here.
  */
_

