From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 25 Jul 2007 05:09:45 +0000
Subject: Re: panic from vector domain patch (was RE: Linus' tree broken?)
Message-Id: <1185340185.14444.16.camel@phobos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185239265.19353.6.camel@phobos>
In-Reply-To: <1185239265.19353.6.camel@phobos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yasuaki,

I added a bunch of printk's to try to better understand this.
ia64_mv.setup does get initialized properly but then gets overwritten.
It appears that it gets overwritten in __bind_irq_vector but I have not
narrowed down exactly where.  I put a printk at the top and bottom of
this function to show what ia64_mv.setup is and I am finding that on the
3rd call to this function it causes ia64_mv.setup to get set to -1.

It is getting way too late for me (1AM here).  I will try to dig into
this more tomorrow but at least I have narrowed it down to a bit of code
that actually is touched by the commit that causes the panic.

- Doug


