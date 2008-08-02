From: Robin Holt <holt@sgi.com>
Date: Sat, 02 Aug 2008 18:07:09 +0000
Subject: Re: [Patch] Update .gitignore to ignore the newly generated
Message-Id: <20080802180709.GB6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This one, of course, goes away now with the rename.

Robin

On Tue, Jul 29, 2008 at 07:03:02AM -0500, Robin Holt wrote:
> 
> Add the generated nr-irqs.h to the .gitignore file.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> Index: contention_unroll/include/asm-ia64/.gitignore
> =================================> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ 2.6.27-rc1/include/asm-ia64/.gitignore	2008-07-29 07:01:45.002716605 -0500
> @@ -0,0 +1 @@
> +nr-irqs.h
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
