From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Tue, 19 Mar 2002 17:20:39 +0000
Subject: RE: [Linux-ia64] mkswap fails to create large swap partitions on
Message-Id: <marc-linux-ia64-105590701905304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905268@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905268@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> >>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:
> 
> >>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
> >>>>> On Thu, 14 Mar 2002 10:54:21 +1100, Peter Chubb 
> <peter@chubb.wattle.id.au> said:
> 
> David> One question though: are you sure about the following line?
> 
> Peter> #define V1_MAX_PAGES ((1 << 24) - 1)
> 
> I've just traced through the code -- the limit should be the lesser of
> (1<<54)-1 and the number of shorts that can be vmalloced in one call,
> in the call
>    p->swap_map = vmalloc(maxpages * sizeof(short))
> in swapfiles.c near line 1029 (2.4.18)
> Unfortunately, I'm not sure (yet) what the maximum such number is.
> 
> Peter C

Peter,

Thanks for looking at this!  I'd been meaning to for a while -- with 32GB+
ram in a machine, 2GB swapfiles weren't really cutting it :-)  Especially
when the default kernel was limited to 8 swapfiles.

I looked through the code (mm/swapfile.c) a little, and I'm not claiming
it all makes sense to me -- how big is a "page" anyway -- but the code
helpfully calls SWAPSPACE2 V2 in the kernel and V1 in mkswap.

Version 1/2 (SWAPSPACE2) appears to not have the page limitation in the
kernel, except for the 54-bit one:
  maxpages = SWP_OFFSET(SWP_ENTRY(0,~0UL)) - 1;

However, the swap_map vmallocs a short (2 bytes) for every "maxpages",
but then the swap_map array is indexed by an int.  So it appears that
the "real" maximum is 2^31-1 (range of a signed int).  [As one example,
scan_swap_map returns an "int" index, and ints occur elsewhere as well.]

So we're okay until about a couple terrabytes is all, until we change
all the index variables to "long". :-)  But even one terrabyte is 16x 64GB.

Also, the kernel should probably try to use "some" of the swap space if it
can't vmalloc storage for the whole thing -- maybe cut p->max in half
until the vmalloc succeeds?  I see the case where you are low on memory
and can't add more swap because you can't allocate enough memory and
the only swapfile you have is 100GB...

Kevin

