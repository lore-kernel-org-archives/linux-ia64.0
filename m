From: Andi Kleen <ak@suse.de>
Date: Thu, 17 Jun 2004 18:54:28 +0000
Subject: Re: sys_ioctl export
Message-Id: <20040617205428.7da56254.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Jun 2004 11:50:36 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> >>>>> On Thu, 17 Jun 2004 20:42:28 +0200, Andi Kleen <ak@suse.de> said:
> 
>   >> AFAIK, there is no ia64-specific reason to export the symbol.  If
>   >> there is a platform-independent reason for doing so, then it
>   >> should be exported for all platform, by putting an
>   >> EXPORT_SYMBOL() after fs/ioctl.c:sys_ioctl().
> 
>   Andi> It's needed to write 32bit compat ioctl handlers in modules.
> 
> That makes sense.

Only partly to be honest. The module count handling for such modules
is currently quite dubious bordering to broken (it's possible to get it right, but
rather difficult) 
 
>   Andi> I would suggest to export it on IA64 too or everywhere.
> 
> Why not export it everywhere then?  It seems strange to allow it to be
> called from modules on 64-bit platforms but not 32-bit platforms.

Just someone has to submit the patch to do and and remove it from
all the archs.

-Andi
