From: Chris Wedgwood <cw@f00f.org>
Date: Wed, 16 Jun 2004 22:04:17 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <20040616220417.GA862@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 02:57:00PM -0700, Jim Wilson wrote:

> I assume you are talking about the first one in
> arch/ia64/kernel/ivt.c.

Yes.

> Current gas seems to get this right without the .pred.rel.

'Current' is what these days? :)

> I see that the LOAD_PHYSICAL macro expansion includes a tag, which
> is kind of like a label.

Yeah, I guess that's true so in this case I'm not sure I can blame gas
entirely, however the scope is limited and it's not actually used
outside of the macro so gas should be able to infer something about
the program flow.

However, since apparently gas does get it right and cases like this
are uncommon I would just ignore it for now.


  --cw
