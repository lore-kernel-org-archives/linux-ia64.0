From: Jes Sorensen <jes@sgi.com>
Date: Tue, 18 Dec 2007 07:49:49 +0000
Subject: Re: [PATCH] arch/ia64/: Spelling fixes
Message-Id: <47677B9D.2070507@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1197919875-5288-6-git-send-email-joe@perches.com>
In-Reply-To: <1197919875-5288-6-git-send-email-joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org

Joe,

I'm curious, do you have a patch that actually fixes something and adds
value to the code? Maybe you could include the spelling fix with that to
improve the S/N ratio?

In addition, posting a patch with no commit comment is no good, please
read through Documentation/SubmittingPatches before posting an update
to this.

Thanks,
Jes


Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  arch/ia64/sn/pci/tioce_provider.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
> index cee9379..e1a3e19 100644
> --- a/arch/ia64/sn/pci/tioce_provider.c
> +++ b/arch/ia64/sn/pci/tioce_provider.c
> @@ -41,7 +41,7 @@
>   *	} else
>   *		do desired mmr access
>   *
> - * According to hw, we can use reads instead of writes to the above addres
> + * According to hw, we can use reads instead of writes to the above address
>   *
>   * Note this WAR can only to be used for accessing internal MMR's in the
>   * TIOCE Coretalk Address Range 0x0 - 0x07ff_ffff.  This includes the

