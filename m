From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Jan 2005 18:28:19 +0000
Subject: RE: [patch] per cpu MCA/INIT fixes.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A674DA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The above will probably conflict with Jack's recent change to 
>stagger the per-node structures by one cacheline.  You may have to rediff 
>against one of Tony's test trees.

I just applied and pushed Jack's patch to the test-2.6.11 tree, Russ, can
you fix up your patch to apply cleanly on top of Jack's.

>> +#ifdef CONFIG_SMP
>> +#include <asm/mca.h>
>> +#endif
>
>Just a nit, header files should always be safe to include 
>unconditionally.  If they're not, the headers need fixing (barring out of tree 
>stuff like kdb of course).

Agreed ... this looks really ugly ... surely we want to support MCA
on uni-processors as well as SMP!  What's the issue that provoked
adding the #ifdef here?

-Tony
