From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 27 Feb 2008 00:15:30 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <1204071330.6836.2.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 2008-02-26 at 16:50 -0700, Alex Chiang wrote:
> * Matthew Wilcox <matthew@wil.cx>:
> > 
> > While you can check to see what SAL revision is supported, do
> > be wary of some prototype HP SAL implementations which report
> > numbers in the 60-90 range.  It's probably safe to say 'if sal
> > revision < 3.2 answer = -1', but we were burned with extended
> > PCI config space many moons ago when we said 'if sal > 3.1 use
> > new method'.
> 
> Ah, good idea, Willy.
> 
> I believe that the current implementation of check_versions()
> does the proper workaround for this bug?
> 
>         /* Check for broken firmware */
>         if ((sal_revision = SAL_VERSION_CODE(49, 29))
>             && (sal_version = SAL_VERSION_CODE(49, 29)))
>         {
>                 /*
>                  * Old firmware for zx2000 prototypes have this weird version number,
>                  * reset it to something sane.
>                  */
>                 sal_revision = SAL_VERSION_CODE(2, 8);
>                 sal_version = SAL_VERSION_CODE(0, 0);
>         }
> 
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
This works for me too.

