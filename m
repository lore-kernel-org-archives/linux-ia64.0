From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Wed, 13 Jun 2007 17:02:04 +0000
Subject: Help!  Need to add a flag to ia64 thread flags
Message-Id: <1181754124.6148.37.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane:

I need to add a flag to the ia64 thread info flags to support my
automigration work.  I was using TIF_NOTIFY_RESUME which you removed.  I
didn't notice that happening, but even if I did, I couldn't/wouldn't
have objected because my patches are still [maybe always?] out of tree.

Now, I've tried to add an automigration-specific flag, called
TIF_MIGRATION_WORK--to the flags to trigger entry to do_notify_resume()
to handle auto-migration.  However, I'm getting errors from the
assembler in arch/ia64/kernel/fsys.S where ever the instruction:

	and r?=TIF_ALLWORK_MASK,r?

occurs, complaining that "Operand 2 of 'and' should be an 8-bit integer
(-128-127)".  This is worrisome to begin with, as thread information
flags comment says that "pending work-to-be-done flags are in
least-significant 16 bits", while the code currently only supports
"8-bits".  What's more interesting is that I've used bit '7' for the
TIF_MIGRATION_WORK flag.  That should fit in the range (-128 - 127),
right?  Maybe the assembler is confused by sign extension of the signed
8-bit int?

For my testing, I can probably use your 'PERFMON_WORK flag, but that's
probably not a good long term solution.  Any ideas how to proceed longer
term to support >7 pending work flags?

Lee

