From: Al Stone <ahs3@fc.hp.com>
Date: Thu, 10 Aug 2006 14:51:46 +0000
Subject: Re: [PATCH] reformat ivt.S for 80-column use
Message-Id: <1155221506.12634.85.camel@deimos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155168978.12634.62.camel@deimos>
In-Reply-To: <1155168978.12634.62.camel@deimos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2006-08-10 at 08:52 -0400, Jes Sorensen wrote:
> >>>>> "David" = David Mosberger-Tang <David.Mosberger@acm.org> writes:
> 
> David> On 10 Aug 2006 03:24:02 -0400, Jes Sorensen <jes@sgi.com>
> David> wrote:
> >> Some of the really complex code is unnecessarily hard to follow due
> >> to this, so I give you my ack!
> 
> David> Huh?  Ever heard of the window resize button?  100 cols will be
> David> just fine.  IA-64 assembly code is one area where it really
> David> helps to have more than 80 cols.  Just my 2 cents, of course...
> 
> It's all a matter of personal preference of course, but I don't like
> resizing my windows depending on what files I am reading. Given that
> CodingStyle calls for 80 columns I prefer to keep my windows at 80
> columns (just as I try to stick to the glibc style when I write glibc
> code, as much as I dislike it).

It is indeed a personal preference; for myself, I don't really care
that much whether it's 80 or 100 (or 132, to _really_ date myself).
The only reasons I had for the patch were (1) personal difficulty with
100-column windows on a laptop (some of us older folks need slightly
larger fonts :), and (2) the recommendations in CodingStyle (independent
of whether I agree with them or not).

-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

