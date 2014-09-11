From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Thu, 11 Sep 2014 10:04:11 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140911110411.2de01944@alan.etchedpixels.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
	<54079B70.4050200@hurleysoftware.com>
	<1409785893.30640.118.camel@pasglop>
	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>
	<1409824374.4246.62.camel@pasglop>
	<5408E458.3@zytor.com>
	<54090AF4.7060406@hurleysoftware.com>
	<54091B30.7080100@zytor.com>
	<5409D76D.2070203@hurleysoftware.com>
	<5409D9C0.7030403@zytor.com>
	<20140908185240.21f52ca0@alan.etchedpixels.co.uk>
	<540DEE6C.2060904@zytor.com>
	<540E3207.7090007@hurleysoftware.com>
In-Reply-To: <540E3207.7090007@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Hurley <peter@hurleysoftware.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

> > Is *that* what we are talking about?  I was added to this conversation
> > in the middle where it had already generalized, so I had no idea.
> 
> No, this is just what brought this craziness to my attention.

None of it is craziness. It's the real world leaking into the crazy
delusional world of sequential programming. Machines are going to get
more not less parallel.

> For example, byte- and short-sized circular buffers could not possibly
> be safe either, when the head nears the tail.
> 
> Who has audited global storage and ensured that _every_ byte-sized write
> doesn't happen to be adjacent to some other storage that may not happen
> to be protected by the same (or any) lock?

Thats a meaningless question. Have you audited it all for correctness of
any other form. Have you mathematically verified the functionality as a
set of formal proofs ? If you can't prove its formally mathematically
functionally correct why are you worried about this ?

Alpha works, maybe it has a near theoretical race on that point. It's not
any worse than it was 15 years ago and nobody has really hit a problem
with it. So from that you can usefully infer that those buffer cases are
not proving a real problem.

The tty locks together on the other hand are asking to hit it, and the
problem you were trying to fix were the ones that need set_bit() to make
the guarantees.

Alan
