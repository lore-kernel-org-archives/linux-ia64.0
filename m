From: James E Wilson <wilson@tuliptree.org>
Date: Mon, 07 Feb 2005 20:11:48 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <1107807108.9243.59.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-02 at 14:50, David Mosberger wrote:
> While I'm in favor of fixing such typos, the Itanium Assembly Language
> Reference Manual states:

The Itanium Assembly Language Reference Manual is badly out of date, and
can no longer be trusted to be accurate.  It hasn't been updated since
2001, but IAS has apparently been updated every year, and no longer
behaves the same as described in the out dated manual.

There are people porting code from the dead Itanium Windows OS to linux
that need gas to behave more like the current IAS.  This is why gas
behaviour is changing.  I'm being careful to try to avoid breaking
anything linux depends on, but the changes include some extra error
checking, which is going to expose some latent problems.

> 	"The assembler ignores the name operands of the
> 	 directive."

I'd call this is a bug in the manual.  Just because one implementation,
at the time the manual was written, ignored the name operand, does not
mean that all assemblers should ignore it.

Also, I'm told that current IAS gives an error in this case, which is
why gas was modified to do likewise.  Unfortunately, I don't have access
to IAS, or to the HP assembler, so I can not check that.  If this is
wrong, then changing it to a warning certainly makes sense.
Otherwise, I don't see the problem with an error here, as the intent of
the syntax is clearly that the .proc/.endp names are supposed to match.

