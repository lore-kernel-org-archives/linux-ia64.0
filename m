From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 17:31:05 +0000
Subject: Re: pipe performance regression on ia64
Message-Id: <16878.39257.133688.118974@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501181741.j0IHfGf30058@unix-os.sc.intel.com>
	<Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org>
	<41ED9D06.1070301@yahoo.com.au>
	<16877.60406.192245.106565@napali.hpl.hp.com>
	<41EE5601.7060700@yahoo.com.au>
In-Reply-To: <41EE5601.7060700@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: davidm@hpl.hp.com, Linus Torvalds <torvalds@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 23:43:45 +1100, Nick Piggin <nickpiggin@yahoo.com.au> said:

  Nick> Oh that's quite true. A bad score on SMP on the pipe benchmark
  Nick> does not mean anything is broken.

  Nick> And IMO, probably many (most?) lmbench tests should be run
  Nick> with all processes bound to the same CPU on SMP systems to get
  Nick> the best repeatability and an indication of the basic serial
  Nick> speed of the operation (which AFAIK is what they aim to
  Nick> measure).

We need to keep an eye on both the intra- and the inter-cpu
pipe-bandwidth and should measure them explicitly.  The problem is
that at the moment, we get one, the other, or a mixture of the two,
subject to the vagaries of the scheduler.  If we could reliably
measure both intra and inter-cpu cases, we may well find new
optimization opportunities (I'm almost certain that's the case for the
cross-cpu case; which is probably the more important case, actually).

	--david
