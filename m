From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 18:36:04 +0000
Subject: Re: [patch] per cpu MCA/INIT fixes.
Message-Id: <200501061036.04379.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 10:21 am, Russ Anderson wrote:
> Yea, I wasn't quite sure what to do about that.  Jack's change had not
> been accepted, so I didn't want to make my change dependent on it.
> His change is only two lines, so it's easy to change my patch if needed.
>
> FWIW, the lines don't conflict and my patch applies correctly on top of
> Jack's change.
>
> patching file arch/ia64/mm/discontig.c
> Hunk #1 succeeded at 350 (offset 2 lines).
> Hunk #2 succeeded at 370 (offset 2 lines).

Oh, ok, that looks good then.  I guess you just need to fix the #ifdef around 
#include <asm/mca.h> then.

Thanks,
Jesse
