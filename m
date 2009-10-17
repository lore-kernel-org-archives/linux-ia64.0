From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sat, 17 Oct 2009 13:43:02 +0000
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
Message-Id: <20091017224028V.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091009164100.85a36188.akpm@linux-foundation.org>
	<20091013021818.GA3898@localhost.localdomain>
	<20091013091017.GA18431@localhost.localdomain>
In-Reply-To: <20091013091017.GA18431@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akinobu.mita@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net, sparclinux@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@ozlabs.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, gregkh@suse.de, LW@KARO-electronics.de, linux-usb@vger.kernel.org, rolandd@cisco.com, yevgenyp@mellanox.co.il, netdev@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-altix@sgi.com

On Tue, 13 Oct 2009 18:10:17 +0900
Akinobu Mita <akinobu.mita@gmail.com> wrote:

> My user space testing exposed off-by-one error find_next_zero_area
> in iommu-helper. Some zero area cannot be found by this bug.
> 
> Subject: [PATCH] Fix off-by-one error in find_next_zero_area
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> ---
>  lib/iommu-helper.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
> index 75dbda0..afc58bc 100644
> --- a/lib/iommu-helper.c
> +++ b/lib/iommu-helper.c
> @@ -19,7 +19,7 @@ again:
>  	index = (index + align_mask) & ~align_mask;
>  
>  	end = index + nr;
> -	if (end >= size)
> +	if (end > size)

I think that this is intentional; the last byte of the limit doesn't
work.
