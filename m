From: Andrew Morton <akpm@osdl.org>
Date: Wed, 04 Feb 2004 19:17:00 +0000
Subject: Re: [PATCH] turn off irqdebug by default on Altix
Message-Id: <20040204111700.2cf6bc80.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin Hicks <mort@bork.org> wrote:
>
> A while ago there was a discussion, started by Jack Steiner, about a hot
>  cache line in the irqdebug code that makes booting on large machines
>  very slow.  The original thread can be found here:
> 
>  http://marc.theaimsgroup.com/?l=linux-kernel&m6858073229831&w=2
> 
>  The end result was that it was felt that irqdebug sould remain on by
>  default on small machines, and that large machines should turn it off be
>  default if it was causing a problem.

Yup.

>  Here is a patch that turns it off for sn2.  It applies cleanly against
>  the linux-2.5 bk tree from this morning.

I think it would be better to kill noirqdebug altogether, and to simply
require irqdebug=N.
