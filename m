From: Grant Grundler <iod00d@hp.com>
Date: Wed, 28 Jan 2004 17:01:53 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <20040128170153.GA5494@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com> <Pine.LNX.4.58.0401271847440.10794@home.osdl.org> <20040128085825.A3591@flint.arm.linux.org.uk>
In-Reply-To: <20040128085825.A3591@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>, Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Wed, Jan 28, 2004 at 08:58:25AM +0000, Russell King wrote:
> On Tue, Jan 27, 2004 at 06:55:17PM -0800, Linus Torvalds wrote:
> > Does anybody see any downsides to something like this?
> 
> What if the failing PCI access happened in an interrupt routine?
> (I'm thinking of the situation where you may need to read the PCI
> status registers to find out whether an error occurred.)

The driver needs to be able to clean up in any context.
That's why I'm advocating what willy called an "exception framework".

While I like linus' suggestion is better than the original,
it spreads the driver error recovery code throughout the driver.
That upside is it can handle every situation.
The downside is numerous error paths makes the regular code alot
harder to read and maintain.

> Also, for that matter, what if a network device receives an abort
> while performing BM-DMA?

The next PIO read will see the error caused by BM-DMA.

> Do we even care about either of these two scenarios?

yes. IO Error recovery has to deal with every scenario.

grant
