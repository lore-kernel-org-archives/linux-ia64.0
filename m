From: Linus Torvalds <torvalds@osdl.org>
Date: Wed, 28 Jan 2004 19:33:33 +0000
Subject: Re: [RFC/PATCH, 2/4] readX_check() performance evaluation
Message-Id: <Pine.LNX.4.58.0401281129570.28145@home.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a301c3e541$c13a6350$2987110a@lsd.css.fujitsu.com>
 <Pine.LNX.4.58.0401271847440.10794@home.osdl.org>
 <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040128182003.GL11844@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>



On Wed, 28 Jan 2004, Matthew Wilcox wrote:
> 
> If there are, Linus' interface is probably the best one.  If not, we could
> simply have readX_check() / writeX_check() call dev->driver->unregister()
> if they notice an error has occurred and then the driver doesn't even
> need to call read_pcix_errors().

What worries me is that not only can the errors be asynchronous, they may 
well be relatively expensive to check for.

For example, if checking for an error involves actually reading a value 
from a bridge register, then that implies some _serious_ amount of 
serialization and external CPU stuff.

The advantage of having the "check for errors" be done later and
independently of the actual IO access itself is not only that I think it
makes the code look nicer - it also allows you to do the IO independently
of the check. Which potentially means that the CPU can burst out the
writes as a burst write, rather than doing them one at a time and then
doing a read of a bridge register in between that serializes everything.

		Linus
