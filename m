From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 05 Apr 2004 16:42:24 +0000
Subject: RE: Missing include in hugetlbpage.c
Message-Id: <200404051642.i35GgOF26741@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jesmfi7cdl.fsf@sykes.suse.de>
In-Reply-To: <jesmfi7cdl.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>> Andreas Schwab wrote on Mon, April 05, 2004 7:01 AM
>
> This fixes a missing include file in arch/ia64/mm/hugetlbpage.c in 2.6.5.
>
> @@ -9,6 +9,7 @@
>   */
>
>  #include <linux/config.h>
> +#include <linux/module.h>
>  #include <linux/init.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>

Just wondering what part depends on that header file, hugetlbpage can't
be module anyway.

- Ken


