From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Fri, 17 Feb 2006 04:23:09 +0000
Subject: Re: [PATCH] Delete a redundant instruction in unaligned_access
Message-Id: <1140150189.15920.11.camel@ymzhang-perf.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140149396.15920.5.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140149396.15920.5.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-02-17 at 12:09, Zhang, Yanmin wrote:
> From: Zhang, Yanmin <yanmin.zhang@intel.com>
> 
> unaligned_access does fetch cr.ipsr, then calls
> dispatch_unaligned_handler, but dispatch_unaligned_handler fetches
> cr.ipsr again, so delete the first one.
> 
> The patch is against kernel 2.6.16-rc3.
> 
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> 
> ---
> 
I don't know why unexpected line breaks appeared. Resend the patch.

---
diff -Nraup linux-2.6.16-rc3/arch/ia64/kernel/ivt.S linux-2.6.16-rc3_fix/arch/ia64/kernel/ivt.S
--- linux-2.6.16-rc3/arch/ia64/kernel/ivt.S	2006-01-25 21:54:04.000000000 +0800
+++ linux-2.6.16-rc3_fix/arch/ia64/kernel/ivt.S	2006-02-18 00:31:08.000000000 +0800
@@ -1362,7 +1362,6 @@ END(debug_vector)
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
 ENTRY(unaligned_access)
 	DBG_FAULT(30)
-	mov r16=cr.ipsr
 	mov r31=pr		// prepare to save predicates
 	;;
 	br.sptk.many dispatch_unaligned_handler


