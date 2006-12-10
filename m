From: Keith Owens <kaos@sgi.com>
Date: Sun, 10 Dec 2006 23:02:52 +0000
Subject: Re: [PATCH 5/5] Itanium MC Error Injection Tool: pal_mc_error_inject() interface
Message-Id: <19385.1165791772@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161731.A1106@unix-os.sc.intel.com>
In-Reply-To: <20061208161731.A1106@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fenghua Yu (on Fri, 8 Dec 2006 16:17:31 -0800) wrote:
>This patch implements pal_mc_error_inject() interface in kernel. Both physical
>mode and virtual mode are supported.
>
>Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>
>
>--- a/include/asm-ia64/pal.h	2006-12-05 18:10:35.000000000 -0800
>+++ b/include/asm-ia64/pal.h	2006-12-05 18:11:12.000000000 -0800
>@@ -80,6 +80,8 @@
> #define PAL_SET_PSTATE		263	/* set the P-state */
> #define PAL_BRAND_INFO		274	/* Processor branding information */
> 
>+#define PAL_MC_ERROR_INJECT	276	/* Injects processor error or returns injection capabilities */

Does this need a particular version of PAL?

