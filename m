From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 18 Jun 2003 03:30:24 +0000
Subject: Re: [Linux-ia64] mkswap fails to create large swap partitions on ia64 [patch]
Message-Id: <marc-linux-ia64-105590701905277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905268@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905268@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peter@chubb.wattle.id.au> writes:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
>>>>> On Thu, 14 Mar 2002 10:54:21 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

David> One question though: are you sure about the following line?

Peter> #define V1_MAX_PAGES ((1 << 24) - 1)

I've just traced through the code -- the limit should be the lesser of
(1<<54)-1 and the number of shorts that can be vmalloced in one call,
in the call
   p->swap_map = vmalloc(maxpages * sizeof(short))
in swapfiles.c near line 1029 (2.4.18)
Unfortunately, I'm not sure (yet) what the maximum such number is.

Peter C

