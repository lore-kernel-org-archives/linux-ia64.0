From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 15 Jan 2009 11:05:08 +0000
Subject: [mmotm][PATCH] fix ia64 build error
Message-Id: <20090115200315.EBE3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>, Kyle McMartin <kyle@mcmartin.ca>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com


Applied after: linux-next.patch
=
Subject: [PATCH] remove duplicate EXPORT_SYMBOL()
Impact: fix build error

In past, ia64_ksyms.c had EXPORT_SYMBOL(copy_page) in wrong place.

old code was

	#include <asm/uaccess.h>
	EXPORT_SYMBOL(__copy_user);
	EXPORT_SYMBOL(__do_clear_user);
	EXPORT_SYMBOL(__strlen_user);
	EXPORT_SYMBOL(__strncpy_from_user);
	EXPORT_SYMBOL(__strnlen_user);
	EXPORT_SYMBOL(copy_page);

(but actually, copy_page is declared in asm/page.h)

And recently, commit bdc2619ab95d45d434c16d5c216bc6243761f6fb insert
EXPORT_SYMBOL(copy_page) into correct place.

then, duplicate EXPORT_SYMBOL create following build error.

arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__kcrctab_copy_page'
arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__kcrctab_copy_page' was here
arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__kstrtab_copy_page'
arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__kstrtab_copy_page' was here
arch/ia64/kernel/ia64_ksyms.c:65: error: redefinition of '__ksymtab_copy_page'
arch/ia64/kernel/ia64_ksyms.c:43: error: previous definition of '__ksymtab_copy_page' was here


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/kernel/ia64_ksyms.c |    1 -
 1 file changed, 1 deletion(-)

Index: b/arch/ia64/kernel/ia64_ksyms.c
=================================--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -40,7 +40,6 @@ EXPORT_SYMBOL(__do_clear_user);
 EXPORT_SYMBOL(__strlen_user);
 EXPORT_SYMBOL(__strncpy_from_user);
 EXPORT_SYMBOL(__strnlen_user);
-EXPORT_SYMBOL(copy_page);
 
 /* from arch/ia64/lib */
 extern void __divsi3(void);


