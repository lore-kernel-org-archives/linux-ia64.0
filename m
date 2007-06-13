From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 13 Jun 2007 17:21:06 +0000
Subject: Re: Help!  Need to add a flag to ia64 thread flags
Message-Id: <20070613172106.GA3002@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1181754124.6148.37.camel@localhost>
In-Reply-To: <1181754124.6148.37.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Lee,

On Wed, Jun 13, 2007 at 01:02:04PM -0400, Lee Schermerhorn wrote:
> Stephane:
> 
> I need to add a flag to the ia64 thread info flags to support my
> automigration work.  I was using TIF_NOTIFY_RESUME which you removed.  I
> didn't notice that happening, but even if I did, I couldn't/wouldn't
> have objected because my patches are still [maybe always?] out of tree.
> 
Welcome to my world!

I remove TIF_NOTIFY_RESUME because it was unused on all but IA-64.
And there it was used by perfmon (v2.0) which I replace by a more
explicit TIF flag.

> Now, I've tried to add an automigration-specific flag, called
> TIF_MIGRATION_WORK--to the flags to trigger entry to do_notify_resume()
> to handle auto-migration.  However, I'm getting errors from the
> assembler in arch/ia64/kernel/fsys.S where ever the instruction:
> 
> 	and r?=TIF_ALLWORK_MASK,r?
> 
> occurs, complaining that "Operand 2 of 'and' should be an 8-bit integer
> (-128-127)".  This is worrisome to begin with, as thread information
> flags comment says that "pending work-to-be-done flags are in
> least-significant 16 bits", while the code currently only supports
> "8-bits".  What's more interesting is that I've used bit '7' for the
> TIF_MIGRATION_WORK flag.  That should fit in the range (-128 - 127),
> right?  Maybe the assembler is confused by sign extension of the signed
> 8-bit int?
> 
Funny! I went through exactly the same thought process when I remove the TIF
flag. Yes, the instruction say imm8, so you'd expect that a 8-bit constant
would fit. But, if you look closer and especially to the pseudo-code describing
the instruction you'll see that there is sign-extension going on, so the
assembler is not wrong. What I do not understand is what's the point of
sign-extension on a AND (bitwise) operation? 

> For my testing, I can probably use your 'PERFMON_WORK flag, but that's
> probably not a good long term solution.  Any ideas how to proceed longer
> term to support >7 pending work flags?
>

In anycase, there is no solution to your problem but to modify entry.S
to deal with the bit-width limitation, i.e, you need to load the constant
into a register and then do the and. You probably understand now, why
I thought is was easier to remove unused TIF flags....


-- 

-Stephane
