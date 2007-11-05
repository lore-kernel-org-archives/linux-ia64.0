From: Simon Horman <horms@verge.net.au>
Date: Mon, 05 Nov 2007 03:23:48 +0000
Subject: Re: [PATCH 2/6] IA64: fix memset size error
Message-Id: <20071105032347.GB15262@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <472E7D34.1040509@cn.fujitsu.com> <472E7DDC.9050806@cn.fujitsu.com>
In-Reply-To: <472E7DDC.9050806@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Mon, Nov 05, 2007 at 10:20:12AM +0800, Li Zefan wrote:
> Li Zefan wrote:
> > The size arguments passing to memset is wrong.
> > 
> > Signed-off-by Li Zefan <lizf@cn.fujitsu.com>

This looks correct to me. Acked.

> > 
> > ---
> >  drivers/video/ps3fb.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> 
> Sorry, please ignore the wrong patch, and here is the right one:
> 
> ---
>  arch/ia64/kernel/efi.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
> index 3f7ea13..0e4ef20 100644
> --- a/arch/ia64/kernel/efi.c
> +++ b/arch/ia64/kernel/efi.c
> @@ -218,7 +218,7 @@ efi_gettimeofday (struct timespec *ts)
>  {
>  	efi_time_t tm;
>  
> -	memset(ts, 0, sizeof(ts));
> +	memset(ts, 0, sizeof(*ts));
>  	if ((*efi.get_time)(&tm, NULL) != EFI_SUCCESS)
>  		return;
>  
> -- 
> 1.5.3.rc7
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

