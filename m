From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 09 Feb 2005 20:05:47 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <20050209200547.GA31021@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 09, 2005 at 11:35:32AM -0800, David Mosberger wrote:
> >>>>> On Mon, 07 Feb 2005 12:11:48 -0800, James E Wilson <wilson@tuliptree.org> said:
> 
>   >> "The assembler ignores the name operands of the
>   >> directive."
> 
>   Jim> I'd call this is a bug in the manual.
> 
> Perhaps.
> 
>   Jim> Also, I'm told that current IAS gives an error in this case, which is
>   Jim> why gas was modified to do likewise.  Unfortunately, I don't have access
>   Jim> to IAS, or to the HP assembler, so I can not check that.  If this is
>   Jim> wrong, then changing it to a warning certainly makes sense.
> 
> Why should it depend on IAS as to whether GAS does or does not produce
> an error?  The fact is that GAS has _not_ in the past issued an error

FYI, I checked the current IAS, the name after endp IS ignored by IAS.

> and it's not acceptable to break existing code for no good reason.
> Making it a warning is fine, of course.  That will alert people to the
> fact that they may have an unintentional inconsistency in their code
> and will let them fix the error at their convenience.  After enough
> time has elapsed (at least a year), the severity could (and probably
> should) be raised to an error.
> 

I guess Jim is still catching his emails. I will give him a few days
to go though my ia64 gas patches which deal this very issues.


H.J.
