From: Dan Pop <Dan.Pop@cern.ch>
Date: Wed, 28 Nov 2001 19:18:18 +0000
Subject: RE: [Linux-ia64] unaligned access?
Message-Id: <marc-linux-ia64-105590698805558@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 28 Nov 2001, Pereira, D LailaX E wrote:

> 
> scp->sc_ip is not properly aligned for an unsigned long access, i.e.
> it is not a multiple of 8.
> 
> Dan
> But , 
> sc_ip field is defined as "unsigned long" in 
> struct sigcontext {
> 	...
> 	unsigned long sc_ip;
> 	...
> }
> 
> ??

The problem is not how it is defined, but what value it contains.  In
your case, its value was not a multiple of 8, hence your problem.

Other people have already explained how to properly use its value to
get the relevant bundle address (clear the least significant 4 bits). 
Do the proper masking in your macro and you should get the expected
results. 

Dan


