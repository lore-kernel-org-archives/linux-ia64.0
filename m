From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 05 Aug 2004 05:05:11 +0000
Subject: Re: Self-tuning logic for the time interpolators?
Message-Id: <Pine.LNX.4.58.0408042202330.17766@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408040934080.14500@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408040934080.14500@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 4 Aug 2004, Andi Kleen wrote:

> > +	else {
> > +		/* Check for the necessity to adjust every minute
> [...]
> > +		if (jiffies >= 2*TIME_ADJUST_COUNTDOWN) {
>
> But INITIAL_JIFFIES is ((unsigned long)(unsigned int) (-300*HZ))
> It will probably not do what you want.

Hmm. I have

/*
 * Have the 32 bit jiffies value wrap 5 minutes after boot
 * so jiffies wrap bugs show up earlier.
 */
#define INITIAL_JIFFIES ((unsigned long)(0))


in 2.6.8-rc2-mm1 (weird comment. There is certainly something to your
post). It works just as intended but I better take that out. Thanks.



