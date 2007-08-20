From: Jes Sorensen <jes@sgi.com>
Date: Mon, 20 Aug 2007 13:24:52 +0000
Subject: Re: Enable early console for Ski simulator
Message-Id: <yq08x86fie3.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
In-Reply-To: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

Peter> When using Ski to debug early startup, it's a bit of a pain not
Peter> to have printk.

Peter> This patch agains 2.6.23-rc? enables the simulated console very
Peter> early.  It may be worth conditionalising on the command
Peter> line... but this is enough for now.

Hi Peter,

Really ugly with extern references in brackets like that - how about
sticking the thing in a header file instead?

Cheers,
Jes
