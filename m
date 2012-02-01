From: Michael Matz <matz@suse.de>
Date: Wed, 01 Feb 2012 17:41:05 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328114266.5355.44.camel@lenny>
 <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
 <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz>
In-Reply-To: <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

Hi,

On Wed, 1 Feb 2012, Jiri Kosina wrote:

> # cat x.c
> struct x {
>     long a;
>     volatile unsigned int lock;
>     unsigned int full:1;
> };
> 
> void
> wrong(struct x *ptr)
> {
>         ptr->full = 1;
> }
> 
> In my opinion, this is a clear bug

Even that depends (sadly) on who you ask.  half-volatile objects (i.e. 
struct where some members are volatile and others aren't) are terribly 
underspecified.  You can make the bitfield volatile, and for ia64 that 
would at least result of ld8.acq/st8.rel pairs.

And Linus: don't be so hastily dismissive.  People (even the compiler 
ones) do agree that using an 8 byte access for a 4 byte entity is 
problematic.  Even if allowed by the standard it's a quality of 
implementation problem.

One problem is that it's not a new problem, GCC emitted similar code since 
about forever, and still they turned up only now (well, probably because 
ia64 is dead, but sparc64 should have similar problems).  The bitfield 
handling code is _terribly_ complex and fixing it is quite involved.  So 
don't expect any quick fixes.

The other problem is specification.  While you think that the code you 
wrote is totally obvious it might not actually be so.  For instance, what 
about this struct:

{long l:32; int i1:16; short s; int i2:1; char c:7; short s2:8; short s3;}

What are the obviously correct accesses for various writes into this 
struct?

One rule may be to never write to a bitfield with accesses larger than 
their underlying declared type.  Well, but only if the bitfield fits into 
that type (int:96 is quite okay to have, and what accesses should be 
allowed there?).  That might be one obvious rule.  But it's not how 
traditional bitfield layout works.  It works based on underlying objects, 
and for that e.g. the three fields i2,c,s are all in the same one, of int 
type.

The rule above would at least work for code that most people do write, 
i.e. sequence of same-typed bitfields mixed with normal members.

And then, there's the last problem: are you sure that if GCC would use 4 
byte accesses for the case at hand, that the hardware wouldn't screw you 
again?  What about using atomic instructions for one half of the 
cache-line (the spinlock) but non-atomic instructions on the other half 
(the bitfield).  Are you sure the latter won't interfere with the former?


Ciao,
Michael.
