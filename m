From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 09 Oct 2003 15:34:28 +0000
Subject: Re: [Gelato-technical] What's still broken?
Message-Id: <marc-linux-ia64-106571413927134@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106569513704299@msgid-missing>
In-Reply-To: <marc-linux-ia64-106569513704299@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 09, 2003 at 08:25:12PM +1000, Peter Chubb wrote:
> Jesse, is the SN2 stuff you're working on so hard going to be included

:)

> in generic builds?  Something like this (which doesn't yet work):

Yep, I've tested it thorougly here, and it works for me.  I don't think
adding the below patch will work until my virtual memmap + discontig
patch (the last one I posted) goes in though.

> --- /tmp/geta1932	2003-10-09 20:13:51.000000000 +1000
> +++ linux-2.5-test7/arch/ia64/Makefile		2003-10-09 20:11:04.000000000 +1000
> @@ -57,7 +57,7 @@
>  core-y				+= arch/ia64/kernel/ arch/ia64/mm/
>  core-$(CONFIG_IA32_SUPPORT)	+= arch/ia64/ia32/
>  core-$(CONFIG_IA64_DIG)	+= arch/ia64/dig/
> -core-$(CONFIG_IA64_GENERIC)	+= arch/ia64/dig/
> +core-$(CONFIG_IA64_GENERIC)	+= arch/ia64/dig/ arch/ia64/sn/
>  core-$(CONFIG_IA64_HP_ZX1)	+= arch/ia64/dig/
>  core-$(CONFIG_IA64_SGI_SN2)	+= arch/ia64/sn/

Thanks,
Jesse
