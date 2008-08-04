From: Robin Holt <holt@sgi.com>
Date: Mon, 04 Aug 2008 20:08:15 +0000
Subject: Re: [Patch 2/2] update generic_defconfig to support sn2.
Message-Id: <20080804200814.GH7290@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080802183527.GA7290@sgi.com>
In-Reply-To: <20080802183527.GA7290@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2008 at 12:27:25PM -0700, Luck, Tony wrote:
> I've locally applied these config updates, but I ran into
> a regression while running my usual set of test builds.
> 
> I build a few uniprocessor configs (by taking files from
> arch/ia64/configs/ and turning off CONFIG_SMP).  The
> resulting uniprocessor generic_defconfig fails to
> build with:
> 
> drivers/misc/sgi-gru/grutables.h:308: error: field `ms_notifier' has incomplete type
> 
> I tried this:
> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
> index 82af385..6e2dcd8 100644
> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -430,7 +430,7 @@ config SGI_XP
>         depends on IA64_GENERIC || IA64_SGI_SN2 || IA64_SGI_UV || (X86_64 && SMP)
>         select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
>         select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
> -       select SGI_GRU if IA64_GENERIC || IA64_SGI_UV || (X86_64 && SMP)
> +       select SGI_GRU if (IA64_GENERIC || IA64_SGI_UV || X86_64) && SMP

Wouldn't this allow a !SMP build to not select GRU?  That is not
correct.  I think this is more a depends on thing, but Dean/Jack are
more appropriate for that question.

Robin
