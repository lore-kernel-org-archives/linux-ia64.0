From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 17 Dec 2002 01:14:43 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805585@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In message <20021216162551.B13547@twiddle.net> you write:
> On Tue, Dec 17, 2002 at 10:22:11AM +1100, Rusty Russell wrote:
> > Could someone who is Attuned with the way of ia64 linking and asm
> > please look at this?  It's a userspace framework which tests the 2.5
> > module code (as modified by RTH to use shared objects rather than
> > simple object files).  You can see 9 architectures already done, but
> > ia64 doesn't work, for reasons beyond my humble abilities.
> 
> This has nothing to do with the icache.

Yes, subject line was stale, sorry for the miscue.

> The program crashes
> the first time it calls through the PLT, *not* on the first
> instruction it executes.
> 
> The PLT has been relocated incorrectly.  More in a moment...

Well, yes, something is wrong with the relocations.  The asm there
looks OK (assuming I'm reading it correctly, which is not guaranteed),
and I thought I put everything in the right place, but obviously not
8(  After two days on and off of trying to get ia64 to work, I passed
the buck. 8(

Thanks for doing the hard work,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

