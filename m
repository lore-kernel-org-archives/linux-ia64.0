From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 19:38:18 +0000
Subject: Re: [PATCH 06/11] xen: move arch/x86/xen/events.c undedr drivers/xen
Message-Id: <47BDD32A.6030201@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080221084530.470680000@ls.local.valinux.co.jp> <20080221091002.222498000@ls.local.valinux.co.jp>
In-Reply-To: <20080221091002.222498000@ls.local.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yamahata@valinux.co.jp
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, xen-devel@lists.xensource.com, linux-ia64@vger.kernel.org, xen-ia64-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>, "Stephen C. Tweedie" <sct@redhat.com>

yamahata@valinux.co.jp wrote:
> diff --git a/arch/x86/xen/events.c b/drivers/xen/events.c
> similarity index 95%
> rename from arch/x86/xen/events.c
> rename to drivers/xen/events.c
> index dcf613e..7474739 100644
> --- a/arch/x86/xen/events.c
> +++ b/drivers/xen/events.c
> @@ -37,7 +37,9 @@
>  #include <xen/interface/xen.h>
>  #include <xen/interface/event_channel.h>
>  
> -#include "xen-ops.h"
> +#ifdef CONFIG_X86
> +# include "../arch/x86/xen/xen-ops.h"
> +#endif

Hm.  Perhaps it would be better to move whatever definition you need 
into a header in a common place (or move xen-ops.h entirely).

    J
