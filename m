From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 16 Jul 2004 07:42:35 +0000
Subject: Re: mf visibility
Message-Id: <20040716074235.GA18712@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F6A0C9.69815A0E@email.mot.com>
In-Reply-To: <40F6A0C9.69815A0E@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 15, 2004 at 10:20:41AM -0500, Mario Smarduch wrote:
> What is the meaning of memory access visibility
> (i.e. mf, rel, acq)? Are memory access with
> deferred response phase visible? For non-deferred
> responses which bus phase determines visibility
> (i.e. bus phase prior to data phase)?

On the Itanium 2 processor these ordering constraints are enforced at
the L2 level (while deciding which requests to issue from the L2 OzQ).
Below this level I presume all requests are treated equally and are
issued in-order to L3 and to the bus.  Given a shared bus topology, as
soon as the request is issued on the bus it can be considered to have
been observed by other agents (assuming each agent then then maintains
order while processing the requests).  I think the response phase
(whether it is deferred or not) is not relevant.

> If there is a more appropriatte news group please
> let me know.

This is the sort of question that would be on-topic for ia64-technical,
the new mailing list I set up recently [1].

Matt

[1] https://gelato.unsw.edu.au/mailman/listinfo/ia64-technical
