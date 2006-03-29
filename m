From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 29 Mar 2006 08:11:51 +0000
Subject: Re: accessed/dirty bit handler tuning
Message-Id: <442A4147.7040005@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> Zoltan,
> 
> The Itanium architects agree with you ... the architecture would allow
> for an implementation where the itc becomes visible after the ld8 that
> is checking the pte hasn't changed.
> 
> Ken and I messed with your patch a bit (to match the style of the rest
> of ivt.S, and to drop some pointless differences between the trap 8, 9
> and 10 handlers).  Here's what I plan to checkin:

Well, it looks correct.

We'll have to have a look at the other places like "vhpt_miss",...

Apparently most of the comments are stripped off :-(

Let me explain why I think it is important to "over-comment" these
low level stuffs, which are far from being self-commenting.

There are a couple non trivial information hidden in these
machine dependent code fragments. We should describe how these
code fragments are meant to work. We should make it as easy as possible
to understand - and criticize - the algorithm for the code readers.
(It replaces the documentation :-).)

There is a second aspect, too: once the algorithm is understood and
agreed upon, the reader can check if the actual implementation is
correct and conform to what is said in the comments.

Otherwise how can someone reading the code know if a "trick" hides
a hilarious idea or it is just a silly bug?

A typical example is the story of our "srlz.d".
I think summarizing what the Itanium architects said about it
could be very much useful.
(And the cache hints...)

Thanks,

Zoltan
