From: Jim Wilson <wilson@specifixinc.com>
Date: Wed, 16 Jun 2004 22:42:40 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <1087425760.1178.82.camel@leaf.tuliptree.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-06-16 at 15:04, Chris Wedgwood wrote:
> 'Current' is what these days? :)

Well, I used something from the binutils cvs tree to check this, but you
may not want to do that.  Whatever is HJ's most recent binutils release
is probably what you should try using.

> Yeah, I guess that's true so in this case I'm not sure I can blame gas
> entirely, however the scope is limited and it's not actually used
> outside of the macro so gas should be able to infer something about
> the program flow.

Tags can't be used for control flow, so that should never have been an
issue.  I believe the problem here is that a label was used before gas
had tag support, and the pred.rel was required at that time.  The
.pred.rel could have been deleted when the label was converted to a tag,
but this was missed in the conversion.

If there is a label here, then there is nothing gas can do except assume
the worst, as gas has no support for building a control flow graph.  Nor
is there any easy place to put it.  Gas is a simple two pass assembler,
one pass to read the input, and a second pass to back patch stuff that
could not be calculated during the first pass.  It isn't possible to
construct a control flow graph until after the first pass, and by then
it is too late, as we have already done all of the dependency violation
analysis during the first pass.  This could be fixed, but it would
require a major rewrite of the IA-64 gas port, and it isn't clear that
this is worth the trouble.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

