From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 28 Jan 2003 21:34:51 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
Message-Id: <marc-linux-ia64-105590709805761@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-=-=

David Mosberger <davidm@napali.hpl.hp.com> writes:

> >>>>> On 28 Jan 2003 11:44:05 -0800, Arun Sharma <arun.sharma@intel.com> said:
> 
>   Arun> David Mosberger <davidm@napali.hpl.hp.com> writes: Hi David,
> 
>   >> I just uploaded the latest ia64 patch to the usual location(s).
>   >> You can get it from ftp.kernel.org/pub/linux/ia64/ports/v2.5/ in
>   >> file:
> 
>   >> linux-2.5.59-ia64-030124.diff.gz
> 
>   Arun> This patch was needed to get the kernel to compile with
>   Arun> hugetlb enabled.
> 
> Your mailer seems to mangle the patch (it seems to convert TABs to
> blanks).  Could you resend the patch as an MIME attachement?
> 

My bad. I did a cut and paste. MIME attachment below.

        -Arun


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=hugetlb.patch

--- linux-2.5.59/arch/ia64/kernel/sys_ia64.c-	Mon Jan 27 19:04:07 2003
+++ linux-2.5.59/arch/ia64/kernel/sys_ia64.c	Mon Jan 27 19:04:16 2003
@@ -16,6 +16,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/highuid.h>
+#include <linux/hugetlb.h>
 
 #include <asm/shmparam.h>
 #include <asm/uaccess.h>
--- linux-2.5.59/arch/ia64/mm/hugetlbpage.c-	Mon Jan 27 18:49:51 2003
+++ linux-2.5.59/arch/ia64/mm/hugetlbpage.c	Tue Jan 28 12:03:16 2003
@@ -242,7 +242,7 @@
 				ret = -ENOMEM;
 				goto out;
 			}
-			add_to_page_cache(page, mapping, idx);
+			add_to_page_cache(page, mapping, idx, GFP_ATOMIC);
 			unlock_page(page);
 		}
 		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);

--=-=-=--


