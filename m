From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 04 Jul 2008 20:41:52 +0000
Subject: Re: the printk problem
Message-Id: <alpine.LFD.1.10.0807041335060.2815@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<20080704132716.f1e12554.akpm@linux-foundation.org>
In-Reply-To: <20080704132716.f1e12554.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Peter Anvin <hpa@zytor.com>



On Fri, 4 Jul 2008, Andrew Morton wrote:
> 
> probe_kernel_address() should be usable here.

Right you are.

> > +static char *string(char *buf, char *end, char *s, int field_width, int precision, int flags)
> > +{
> > +	int len, i;
> > +
> > +	if ((unsigned long)s < PAGE_SIZE)
> > +		s = "<NULL>";
> 
> hm, is that needed for other reasons than "it will fault"?

It's similar to what glibc does - showing a NULL ptr gracefully. They are 
pretty common, and it's very rude to SIGSEGV or oops just because you 
wanted to print a string out for debugging.

The code is also just copied from the old code - just moved it to a 
function of its own.

> otherwise we could walk the whole string with probe_kernel_address()
> before we do anything with it.

That would be pretty slow, wed' be better off then unrolling it (ie doing 
all the ugly setup around the whole string).

> If this takes off we might want a register-your-printk-handler
> interface.  Maybe.

Yeah. 

> We also jump through hoops to print things like sector_t and
> resource_size_t.  They always need to be cast to `unsiged long long',
> which generates additional stack space and text in some setups.

Indeed. Though doing it with a pointer is often not a _whole_ lot cleaner, 
but yes, it's often nicer to add a '&' than adding a cast.

> And then there's the perennial "need to cast u64 to unsigned long long
> to print it".  If we were to do
> 
> 	printk("%SL", (void *)some_u64);
> 
> then that's still bloody ugly, but it'll save a little text-n-stack.

No can do. (void *) isn't big enough to hold a u64. So it would have to be 
something like this:

	printk("%p64i", &some_u64);

instead. Avoiding the cast, and often being more efficient calling 
convention on 32-bit.

But it can often generate worse code too - now we're taking an address of 
a variable, and that will disable many optimizations because now i's not a 
purely local variable that the compiler knows all uses for any more.

So I'm not entirely conviced it's a good idea to do this for just "long 
long" cases. Dunno.

		Linus
