From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Mon, 15 Oct 2018 19:15:00 +0000
Subject: Re: [PATCH] ia64: enable GENERIC_HWEIGHT
Message-Id: <20181015201500.49b4a487@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180914070646.29273-1-slyfox@gentoo.org>
In-Reply-To: <20180914070646.29273-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, 14 Sep 2018 08:06:46 +0100
Sergei Trofimovich <slyfox@gentoo.org> wrote:

> Noticed on a single driver failure:
>   ERROR: "__sw_hweight8" [drivers/net/wireless/mediatek/mt76/mt76.ko] undefined!
> 
> CC: Tony Luck <tony.luck@intel.com>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: linux-ia64@vger.kernel.org
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> ---
>  arch/ia64/Kconfig | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index 8b4a0c1748c0..1a71f92f0b8e 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -576,3 +576,7 @@ config MSPEC
>  	  If you have an ia64 and you want to enable memory special
>  	  operations support (formerly known as fetchop), say Y here,
>  	  otherwise say N.
> +
> +config GENERIC_HWEIGHT
> +	bool
> +	default y
> -- 
> 2.19.0
> 

Ping.

-- 

  Sergei
