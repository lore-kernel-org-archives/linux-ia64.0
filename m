From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 31 May 2003 01:31:18 +0000
Subject: Re: [Linux-ia64] sigaltstack and ar.bspstore
Message-Id: <marc-linux-ia64-105590723706100@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 30, 2003 at 09:32:03AM -0700, David Mosberger wrote:
> 
>   Matt> I'd propose that the trampoline code should save bspstore in
>   Matt> the sigcontext structure and restore it from there rather than
>   Matt> recalculating it.  I can send a patch, but first is there any
>   Matt> reason why it shouldn't be done that way?
> 
> My preference would be to fix it in a way that preserves binary
> compatibility for the sigcontext structure.

I wasn't suggesting changing the layout, I was suggesting using one of
the reserved slots.  Unless you're referring to software that changes
sc_ar_bsp...

I don't think there's currently enough information available upon return
from the signal handler to decide whether to point bspstore at slot 63
or 0.  It wouldn't be safe to always go for slot 63 because it might be
beyond the start of the RBS.

Matt


