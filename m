From: Horms <horms@verge.net.au>
Date: Tue, 20 Mar 2007 04:29:17 +0000
Subject: Re: [PATCH] fix an IA64 MCA kdump bug in kdump_init_notifier
Message-Id: <20070320042916.GB3863@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <45FF431C.1040607@sgi.com>
In-Reply-To: <45FF431C.1040607@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 20, 2007 at 01:53:51PM +1100, Keith Owens wrote:
> Horms (on Tue, 20 Mar 2007 11:34:28 +0900) wrote:
> >On Mon, Mar 19, 2007 at 07:12:44PM -0700, Jay Lan wrote:
> >> Since DIE_INIT_SLAVE_ENTER is a non-zero value, thus "nd->sos->rv_rc
> >> =1" is always evaluated. The kdump kernel aborted because nd->sos
> >> is NULL in (at least some) MCA cases.
> >
> >I think that your fix below does correct a problem,
> >in that "|| DIE_INIT_SLAVE_ENTER" appears to be quite bogus.
> >But if you are worried about nd->sos being NULL, is it worth checking
> >for that explicitly. Or will it always be non-NULL with the code below?
> 
> nd->sos is only (and always) defined for the MCA/INIT SAL to OS
> handlers.  nd->sos is NULL for events such as MCA rendezvous interrupt,
> since that event runs on the normal kernel stack.

Thanks for the clarification.

In that case.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

