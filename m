From: "Bob Picco" <bob.picco@hp.com>
Date: Mon, 16 Jul 2007 10:07:44 +0000
Subject: Re: [PATCH 1/2] ia64 clocksource
Message-Id: <20070716100744.GA10653@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:	[Sat Jul 14 2007, 06:25:39AM EDT]
> On Fri, Jul 13, 2007 at 08:25:09PM -0400, Bob Picco wrote:
> > 
> > Andrew and Tony:
> > 
> > I'd like to get this into -mm with the intent of targeting for 2.6.24. There
> > is only documentation change since Pete's last posting on ia64 ml. I doubt
> > Pete's email address exists because of his early retirement the end of May.
> 
> What's the reason not to put it into 2.6.23?  The code has been around for
> quite a long time, and finishing the transition to get rid of the timer
> interpolator ASAP would be very valueable.
> 
John and I discussed the strategy. We felt more testing time in -mm would
be best. I could be wrong but Pete and I are probably the only two
testers of the code.

bob
