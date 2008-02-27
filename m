From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 27 Feb 2008 00:00:10 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080227000010.GB5715@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 04:50:48PM -0700, Alex Chiang wrote:
> I believe that the current implementation of check_versions()
> does the proper workaround for this bug?
> 
>         /* Check for broken firmware */
>         if ((sal_revision = SAL_VERSION_CODE(49, 29))
>             && (sal_version = SAL_VERSION_CODE(49, 29)))
>         {

Oh, there were many other broken versions available ;-)  I believe this
particular workaround was for a machine David Mosberger had that
couldn't be upgraded.

> In light of that, how about this patch? It allows my Tiger to
> boot.
> 
> /ac
> 
> From: Alex Chiang <achiang@hp.com>
> Subject: [PATCH] ia64: ia64_sal_physical_id_info work around broken SAL
> 
> Unimplemented SAL calls should return -1, but on at least one
> platform (Tiger with SAL v3.1), attempting to call SAL_PHYSICAL_ID_INFO
> (which was defined in SAL v3.2 and later) results in an oops and
> a hang.
> 
> Signed-off-by: Alex Chiang <achiang@hp.com>

Acked-by: Matthew Wilcox <willy@linux.intel.com>

> ---
> diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
> index 2251118..f4904db 100644
> --- a/include/asm-ia64/sal.h
> +++ b/include/asm-ia64/sal.h
> @@ -807,6 +807,10 @@ static inline s64
>  ia64_sal_physical_id_info(u16 *splid)
>  {
>         struct ia64_sal_retval isrv;
> +
> +       if (sal_revision < SAL_VERSION_CODE(3,2))
> +               return -1;
> +
>         SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
>         if (splid)
>                 *splid = isrv.v0;
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
