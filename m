From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 Apr 2004 20:30:42 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <16521.31986.396574.223788@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 23 Apr 2004 14:43:33 +0200 (CEST), Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net> said:

  Jean-Marc> Hello David, On Wed, 21 Apr 2004, David Mosberger wrote:

  >> Yes, the code is probably fine, but I think it could be
  >> structured better for better.

  Jean-Marc> Do you mean there should be more generic code to handle
  Jean-Marc> the same problem for other relocation types? BTW, do you
  Jean-Marc> have any hints as to which types need to be fixed besides
  Jean-Marc> PCREL21B?

  Jean-Marc> Also, you mentioned formatting problems in the patch, but
  Jean-Marc> I can't see any.

Sorry, my typos don't help: what I meant to say is "structured for
better readability".  I really do think the code should distinguish
between internal vs. external references, with internal further
breaking down into intra- vs. inter-segment (with init vs. core being
viewed as two different segments).

  >> BTW: a PLT is also a bit of overkill.  What you're doing is
  >> similar to what the GNU linker calls "relaxation" (extending the
  >> reach of a branch), since the gp value is the same for the caller
  >> and the callee.

  Jean-Marc> Indeed, but the only benefit I can see is that we could
  Jean-Marc> use a smaller plt entry that does not update gp and
  Jean-Marc> simply branches to the target. Only module .init code is
  Jean-Marc> impacted, so I'm not sure it is worth handling it
  Jean-Marc> differently.

I'm not sure either but I think it should be explored.  If the code
comes out nicer and cleaner, I'd certainly prefer that approach.  I'm
not so much worried about the savings, but about introducing different
kinds of bugs or maintenance head-ache.  It's generally a bad idea to
treat two different things the same just because they happen to be
able to share _some_ code.  In my experience, that often leads to
troubles further down the road.  I'm pretty sure we need to
distinguish inter-module-calls and inter-segment branches at least
logically, even if it turns out that at the lowest level, they're both
implemented with the same kind of stubs.  For example, for
inter-module calls you know you only have to handle br.call/brl.call,
whereas there is no such guarantee for inter-segment calls.

	--david
