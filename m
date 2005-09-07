From: david mosberger <dmosberger@gmail.com>
Date: Wed, 07 Sep 2005 01:10:40 +0000
Subject: Re: [patch] make exception handler in copy_user more robust
Message-Id: <ed5aea4305090618101093a1bd@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509062306.j86N64g19803@unix-os.sc.intel.com>
In-Reply-To: <200509062306.j86N64g19803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since we no longer support GCC 2.x, could that code perhaps be
simplified by taking advantage of tags?

  --david

On 9/6/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> The exception handler in copy user always expects fault occurs only on
> user space address and the fall back recovery code is written with that
> very assumption in mind.  Recent source code inspection revealed that
> while it worked splendid and to the expectation under normal circumstances,
> It broke down under unexpected condition where some address calculation
> might go outside the legal address range the original copy_user was
> called for.  This patch is to make copy_user exception handler more robust
> and to prevent potential memory corruption.
> 
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> 
> --- linux-2.6.13/arch/ia64/lib/memcpy_mck.S.orig        2005-09-06 15:15:29.560795174 -0700
> +++ linux-2.6.13/arch/ia64/lib/memcpy_mck.S     2005-09-06 15:21:46.798095240 -0700
> @@ -625,8 +625,11 @@ EK(.ex_handler,  (p17)     st8     [dst1]=r39,8)
>         clrrrb
>         ;;
>         alloc   saved_pfs_stack=ar.pfs,3,3,3,0
> +       cmp.lt  p8,p0=A,r0
>         sub     B = dst0, saved_in0     // how many byte copied so far
>         ;;
> +(p8)   mov     A = 0;                  // A shouldn't be negative, cap it
> +       ;;
>         sub     C = A, B
>         sub     D = saved_in2, A
>         ;;
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
