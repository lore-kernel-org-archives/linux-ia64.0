From: Tim Schmielau <tim@physik3.uni-rostock.de>
Date: Fri, 04 Feb 2005 00:41:39 +0000
Subject: Re: move-accounting-function-calls-out-of-critical-vm-code-paths.patch
Message-Id: <Pine.LNX.4.53.0502040130230.5666@gockel.physik3.uni-rostock.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050110184617.3ca8d414.akpm@osdl.org>
 <Pine.LNX.4.58.0502031319440.25268@schroedinger.engr.sgi.com>
 <20050203140904.7c67a144.akpm@osdl.org> <Pine.LNX.4.58.0502031436460.26183@schroedinger.engr.sgi.com>
 <20050203150551.4d88f210.akpm@osdl.org>
In-Reply-To: <20050203150551.4d88f210.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>, jlan@sgi.com, Guillaume Thouvenin <guillaume.thouvenin@bull.net>

On Thu, 3 Feb 2005, Andrew Morton wrote:

> Well your patch certainly cleans things up in there and would be a good
> thing to have as long as we can be sure that it doesn't break the
> accounting in some subtle way.

I think it also fits well with the other accounting data which is only 
statistically probed at clock ticks.

> Which implies that we need to see some additional accounting code, so we
> can verify that the base accumulation infrastructure is doing the expected
> thing.  As well as an ack from the interested parties.  Does anyone know
> what's happening with all the new accounting initiatives?  I'm seeing no
> activity at all.

Well, I'm here :), but I'm concentrating on making a GNU acct release 
happen.
Anyways, as I'm not involved with memory accounting yet, I guess I should 
leave it to CSA and ELSA people to comment.

Tim
