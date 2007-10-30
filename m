From: Simon Horman <horms@verge.net.au>
Date: Tue, 30 Oct 2007 07:15:13 +0000
Subject: Re: [PATCH] fix typo in per_cpu_offset
Message-Id: <20071030071513.GE5361@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0710230015x1640388aod98cae2fa3fc82c2@mail.gmail.com>
In-Reply-To: <3877989d0710230015x1640388aod98cae2fa3fc82c2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Oct 23, 2007 at 03:15:55PM +0800, Luming Yu wrote:
> Hello list,
> 
> there is a typo in the definition of per_cpu_offset because, for ia64,
> the __per_cpu_offset is an array.
> 
>  extern unsigned long __per_cpu_offset[NR_CPUS];
> -#define per_cpu_offset(x) (__per_cpu_offset(x))
> +#define per_cpu_offset(x) (__per_cpu_offset[x])
> 
> Thanks,
> Luming
> 
> Signed-off-by: Yu Luming <luming.yu@intel.com>

This looks correct to me, and gcc seems to agree too.

Though curiuously with my config nothing uses per_cpu_offset()
(I added a bogus call to produce an error.) Is it actually
used on ia64?

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

