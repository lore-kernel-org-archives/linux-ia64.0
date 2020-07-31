From: Jonathan Corbet <corbet@lwn.net>
Date: Fri, 31 Jul 2020 17:09:33 +0000
Subject: Re: [PATCH] docs: ia64: correct typo
Message-Id: <20200731110933.4edfc99c@lwn.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1596104250-32673-1-git-send-email-Julia.Lawall@inria.fr>
In-Reply-To: <1596104250-32673-1-git-send-email-Julia.Lawall@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <Julia.Lawall@inria.fr>
Cc: Tony Luck <tony.luck@intel.com>, kernel-janitors@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 30 Jul 2020 12:17:30 +0200
Julia Lawall <Julia.Lawall@inria.fr> wrote:

> Replace RTC_WKLAM_RD with RTC_WKALM_RD.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@inria.fr>
> 
> ---
>  Documentation/ia64/efirtc.rst |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/ia64/efirtc.rst b/Documentation/ia64/efirtc.rst
> index 2f7ff50..fd83284 100644
> --- a/Documentation/ia64/efirtc.rst
> +++ b/Documentation/ia64/efirtc.rst
> @@ -113,7 +113,7 @@ We have added 2 new ioctl()s that are specific to the EFI driver:
>  
>  	Read the current state of the alarm::
>  
> -		ioctl(d, RTC_WKLAM_RD, &wkt)
> +		ioctl(d, RTC_WKALM_RD, &wkt)

Applied to the docs tree, thanks.

jon
