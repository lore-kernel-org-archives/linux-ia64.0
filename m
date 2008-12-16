From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Tue, 16 Dec 2008 23:43:58 +0000
Subject: Re: local_add_return
Message-Id: <20081216234358.GC5584@osiris.boeblingen.de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.1.10.0812150823370.18692@gandalf.stny.rr.com> <200812161703.00697.rusty@rustcorp.com.au> <20081215.231314.92267481.davem@davemloft.net> <200812170908.05423.rusty@rustcorp.com.au>
In-Reply-To: <200812170908.05423.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca, paulus@samba.org, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org

On Wed, Dec 17, 2008 at 09:08:04AM +1030, Rusty Russell wrote:
> On Tuesday 16 December 2008 17:43:14 David Miller wrote:
> > Here ya go:
> 
> Very interesting.  There's a little noise there (that first local_inc of 243
> is wrong), but the picture is clear: trivalue is the best implementation for
> sparc64.
> 
> Note: trivalue uses 3 values, so instead of hitting random values across 8MB
> it's across 24MB, and despite the resulting cache damage it's 15% faster.  The
> cpu_local_inc test is a single value, so no cache effects: it shows trivalue
> to be 3 to 3.5 times faster in the cache-hot case.
> 
> This sucks, because it really does mean that there's no one-size-fits-all
> implementation of local_t.  There's also no platform yet where atomic_long_t
> is the right choice; and that's the default!
> 
> Any chance of an IA64 or s390 run?  You can normalize if you like, since
> it's only to compare the different approaches.

atomic_long_t seems to be the right choice on s390. IRQ disable/enable is
expensive, but the compare and swap instruction is cheap. I just gave it
a quick shot, but please note that there were two hypervisors running below
my system (add_return is missing since I used your first patch):

atomic_long	19  18  -  3  17
irqsave/rest	57  58  - 39  22
trivalue	43  43  -  4  45
local_t		18  20  -  2  16
