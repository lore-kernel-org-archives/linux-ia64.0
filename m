From: Grant Grundler <iod00d@hp.com>
Date: Mon, 19 Jan 2004 18:18:08 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040119181808.GA4225@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040116003224.GF23253@kroah.com> <20040116050059.GA13222@cup.hp.com> <023b01c3de6f$10276820$2987110a@lsd.css.fujitsu.com>
In-Reply-To: <023b01c3de6f$10276820$2987110a@lsd.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>
Cc: Greg KH <greg@kroah.com>, Jesse Barnes <jbarnes@sgi.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Mon, Jan 19, 2004 at 06:31:42PM +0900, Hironobu Ishii wrote:
> But, when the read thread continues without noticing the error
> (before the error is asynchronously notified),

I wasn't suggesting asynchonous notification.

> the thread runs based on wrong data and may panic.

So far I've been assuming resources/IO requests can be cleaned up
more easily in a shared code path. I was assuming the readb() would 
call the "cleanup" and then return a "harmless" value (eg. 0 or -1)
that was provided by the driver before hand. I'm more worried
about the code that evaluates the readb() return value than
synchronous notification or cleaning up resources.

Having unique error recovery code after each PIO read did work
but it was not an elegant solution. It was a problem of too much
"unused" code interferring with the regular code path. And it
didn't distinguish sufficiently between code to handle "platform"
errors (failure to talk to a card) vs card errors (card
failed an IO).

I guess I'd need to modify one driver using my proposal
instead of assuming it doesn't matter wether the recovery code
lives immediately after the PIO read or in some common routine.
Problem is I have other issues to deal with right now
even though I've made clear to my management "HW error recovery"
is required for higher levels of availability with linux.

> So I think PIO read error must be notified synchronously.

I agree.

> On the other hand, PIO write error can be notified asynchronously,
> because software does not use it.

yes.

thanks,
grant
