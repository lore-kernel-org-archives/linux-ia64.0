From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 25 Aug 2004 23:23:25 +0000
Subject: Re: [RFC&PATCH 1/2] PCI Error Recovery (readX_check)
Message-Id: <1093476204.2170.55.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <412AD123.8050605@jp.fujitsu.com>
	 <Pine.LNX.4.58.0408232231070.17766@ppc970.osdl.org>
	 <1093417267.2170.47.camel@gaston>
	 <Pine.LNX.4.58.0408250015420.17766@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0408250015420.17766@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org


> The "good news" is that I doubt very many drivers will care enough to do
> this. I suspect you'll only have a few very specific drivers used in 
> fault-tolerant circumstances, where you care more about the errors than 
> about the inevitable serialization.

Yup, but then, the user have to take care that behind a single "error
checking" entity (a bridge for example), all devices have such drivers
that honor the bridge-level locking and not their own.

On ppc64, I think we always have 1 bridge = 1 slot though, makes things
easier (well, provided we don't start to try playing with error coming
from slots on the g5).

> > I don't know what is the best thing to do here... The arch is the one to
> > know what is the granularity of the error management (per slot ? per segment
> > or per domain ?) and so to know what kind of lock is needed...
> 
> It will have to depend on the bus setup. Not arch-specific per se, but 
> clearly specific to the bus controllers in question. 

Right.

Ben.


