From: Linus Torvalds <torvalds@osdl.org>
Date: Tue, 27 Jul 2004 17:14:08 +0000
Subject: Re: next 3 months
Message-Id: <Pine.LNX.4.58.0407271012120.2522@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407271704.i6RH4SQU024357@napali.hpl.hp.com>
In-Reply-To: <200407271704.i6RH4SQU024357@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, 27 Jul 2004, David Mosberger wrote:
>
> As you may have heard [1], Linus isn't planning on opening up a 2.7
> tree anytime soon (or perhaps ever).  Instead, the idea is to put
> experimental/new stuff in Andrew's mm tree and then trickle them into
> Linus' tree,

Well, yes and no. I'll also open a 2.7.x "microbranch" that is _only_ for
stuff that is really experimental and has 2.8.x potential. But unlike
before, the 2.7 branch is supposed to be tracking 2.6.x, so as far as most
development is concerned, you're right - 2.6.x is the place for any
"normal" stuff (ie stuff that isn't expected to be very painful for
users).

		Linus
