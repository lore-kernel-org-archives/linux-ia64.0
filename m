From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 09 May 2007 02:41:41 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <1178678501.2613.12.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2007-05-08 at 15:26, Simon Horman wrote:
> On Tue, May 08, 2007 at 09:13:18AM +0800, Zou Nan hai wrote:
> > 
> > Hi Tony,
> >       If the per-cpu TR entry is removed, 
> >       I think the relocate_kernel.S also need a fix to remove the
> per-cpu TR
> > purge code.
> 
> Just to clarify, is this what you are thinking about?
> If so, it seems sensible to me.
> 
> Index: linux-2.6-ia64/arch/ia64/kernel/relocate_kernel.S
> =================================> --- linux-2.6-ia64.orig/arch/ia64/kernel/relocate_kernel.S     
> 2007-05-08 16:15:05.000000000 +0900
> +++ linux-2.6-ia64/arch/ia64/kernel/relocate_kernel.S   2007-05-08
> 16:25:23.000000000 +0900
> @@ -104,15 +104,6 @@ GLOBAL_ENTRY(relocate_new_kernel)
>          srlz.i
>          ;;
>  
> -       // purge TR entry for percpu data
> -        movl r16=PERCPU_ADDR
> -        mov r18=PERCPU_PAGE_SHIFT<<2
> -        ;;
> -        ptr.d r16,r18
> -        ;;
> -        srlz.d
> -       ;;
> -
>          // purge TR entry for pal code
>          mov r16=in3
>          mov r18=IA64_GRANULE_SHIFT<<2
> 

Yes that is what I think. 

Thanks
Zou Nan hai
