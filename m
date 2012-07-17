From: Theodore Ts'o <tytso@mit.edu>
Date: Tue, 17 Jul 2012 17:12:51 +0000
Subject: Re: [PATCH -next] random: Remove remaining relicts of rand_initialize_irq()
Message-Id: <20120717171251.GD6049@thunk.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1342524793-2522-1-git-send-email-sedat.dilek@gmail.com>
In-Reply-To: <1342524793-2522-1-git-send-email-sedat.dilek@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Linus Walleij <linus.walleij@stericsson.com>, Samuel Ortiz <sameo@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jul 17, 2012 at 01:33:13PM +0200, Sedat Dilek wrote:
> rand_initialize_irq() was removed here:
> 
> commit 946672f548682905d8ecdab33bb6e2c705418505
> "random: remove rand_initialize_irq()"
> 
> The AB3100 mfd-driver is the only driver still using it and breaks
> with the following error-messages in linux-next (next-20120717)

Oops.  Sorry, I thought I had caught all of the users of
rand_initialize_irq().  Thanks for catching this!

I'll take your advice and merge it into the original commit.

     	       	      	  	   	- Ted
