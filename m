From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 09 Feb 2005 20:10:13 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <1107979813.19059.45.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-09 at 11:35, David Mosberger wrote:
> Why should it depend on IAS as to whether GAS does or does not produce
> an error?

I was wrong about IAS giving an error in this case (.proc/.endp).  I
mentioned this in an earlier mail.  See Jan's response for the
clarification.

It has always been the goal since the beginning to be compatible with
IAS.  Unfortunately, the gas IA-64 port was never finished.  There is
some stuff that was never implemented, some stuff that was incorrectly
and/or incompletely implemented, and some stuff that is known to be
buggy.  The gas IA-64 port is suffering from a lack of attention. 
Fortunately, there is only one major bug, the DV support is fatally
flawed and has to be rewritten, and at the moment this problem is
limited by the fact that the gcc predication support is not smart enough
to emit code that gas can't handle correctly.

Anyways, these gas problems all need to be fixed eventually.  I do want
to avoid breaking existing code unnecessarily, but it may not be
possible in all cases.

> The fact is that GAS has _not_ in the past issued an error
> and it's not acceptable to break existing code for no good reason.
> Making it a warning is fine, of course.

I believe there is a good reason for this.  We are talking about
directives related to unwind info.  Unwind info only gets tested when
exceptional conditions occur, at which point it is too late to recover. 
It is important that the assembler give an error if a problem is
detected, as otherwise a serious latent bug may go unfixed.  I we give a
warning, then people may not notice it and fix their code.

However, I do understand that there is some inconvenience here.  I have
no problem with emitting a warning temporarily to give people a chance
to migrate.  In fact, I believe I will have to use a warning for now
because these changes break gcc -pg, and this is not easy to fix as it
will also require glibc changes.  I already have a patch from HJ to do
this, I just need to review it.

