From: Richard Henderson <rth@redhat.com>
Date: Wed, 05 Dec 2001 16:58:08 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805617@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805617@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 05, 2001 at 03:23:04AM -0800, David S. Miller wrote:
> I don't understand why this is even necessary.
> 
> What if the interrupt comes in on another processor.  How does this
> return from trap behavior avoid that interrupt modifying the signal
> and/or scheduling state wrt. the current cpu's task?

It doesn't.  But it also prevents the IPI from being recognized
until we are back in userland.  Apparently DMT had a test case
that failed without disabling interrupts; I didn't see it myself.


r~

