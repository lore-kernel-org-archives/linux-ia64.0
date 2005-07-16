From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Sat, 16 Jul 2005 12:55:27 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD54FA8D8@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Looks nice.  One thing that bothers me is that privop.h is unsymmetic,
> I'd rather see the Xen variants of the routines in 
> asm/privop.h aswell.

Thanks!  Do you mean like:

#ifdef CONFIG_XEN
#include <asm/xen/privop.h>
#define privop1 xen_privop1
#define privop2(x) xen_privop2(x)
 :
#else
#define privop1 __privop1
#define privop2(x) __privop2(x)
 :
#endif

> Also in the early console setup please put the return on a 
> separate line
> from the if clause.

OK, will do in Rev4.

> It would be very nice if you could submit the additional abstractions
> as a first patch as soon as possible and post a full patch ontop of it
> later that includes the new files aswell.

That's the plan.

Thanks very much for the feedback!
Dan
