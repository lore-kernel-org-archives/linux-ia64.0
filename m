From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 23 Jul 2009 21:28:09 +0000
Subject: Re: [PATCH] ia64: minor Makefile simplification through use of
Message-Id: <20090723212809.GB9488@merkur.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200907232056.51064.elendil@planet.nl>
In-Reply-To: <200907232056.51064.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Frans Pop <elendil@planet.nl>
Cc: linux-ia64@vger.kernel.org, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 23, 2009 at 08:56:50PM +0200, Frans Pop wrote:
> Signed-off-by: Frans Pop <elendil@planet.nl>
> ---
> 
> Change was suggested by Sam Ravnborg; see http://lkml.org/lkml/2009/7/18/15.
> Untested.
> 
> diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
> index 58a7e46..2bf6107 100644
> --- a/arch/ia64/Makefile
> +++ b/arch/ia64/Makefile
> @@ -41,10 +41,8 @@ $(error Sorry, you need a newer version of the assember, one that is built from
>  		ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz)
>  endif
>  
> -ifeq ($(call cc-version),0304)
> -	cflags-$(CONFIG_ITANIUM)	+= -mtune=merced
> -	cflags-$(CONFIG_MCKINLEY)	+= -mtune=mckinley
> -endif
> +cflags-$(CONFIG_ITANIUM)  += $(call cc-ifversion, -eq, 0304, -mtune=merced)
> +cflags-$(CONFIG_MCKINLEY) += $(call cc-ifversion, -eq, 0304, -mtune=mckinley)

The above change is correct.
But I really wonder if the original code was correct?
Do we really only want to use the -mtune options for this specific gcc version?
If this is indeed the case this deserves a comment explaning this.

So the patch has my:

Acked-by: Sam Ravnborg <sam@ravnborg.org>

But the code that this patch highligt (but does not chage) looks questionable.

	Sam
