From: Horms <horms@verge.net.au>
Date: Mon, 13 Mar 2006 08:12:41 +0000
Subject: Re: [RFC] IA64: Use early_parm to handle mvec_name and nomca
Message-Id: <20060313081241.GA2160@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060310082445.GA18715@verge.net.au>
In-Reply-To: <20060310082445.GA18715@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Mar 12, 2006 at 10:33:27PM -0800, Chen, Kenneth W wrote:
> Horms wrote on Sunday, March 12, 2006 8:08 PM
> > IA64: Use early_parm to handle mvec_name and nomca
> > 
> > I'm not sure of the worthiness of this idea, so please consider it an RFC. 
> > Its key merits are:
> > 
> > * Reuse existing infrastructure
> > * Greatly tightens up the parsing of nomca
> > * Greatly simplifies the parsing of machvec
> 
> It is kind of odd though that parse_early_param() is called twice,
> once from init/main.c:start_kernel and once from arch/ia64/kernel/
> setup.c:setup_arch.  Though you are not the one introduces that
> Oddity.

Yes, that is odd. I guess the arch/ia64/kernel/setup.c one could be
removed. That is, unless the init/main.c is called too late. I'll
investigate that.

> The other thing is that the code you changed are going to be thrown
> away after initialization, so I take your motivation of the patch
> is in some form of uncluttered the source code?

Yes. It seems to me that the parsing is greatly simplified with this
approach.

> If I were you, I would put machvec code into machvec.c, like this:

That is an excellent idea.

-- 
Horms
