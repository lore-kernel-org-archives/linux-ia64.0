From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 26 May 2006 18:25:21 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F06973A6C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Just for clarity, what platforms would be affected by this?  I thought
> the non-free software was needed for Montecito+, and that Madison
> worked fine w/o it.

You are correct.  All cpu implementations prior to "Montecito" have
h/w support for x86 instructions.  "Montecito" does not.  You'll
have to make your own bets and guesses about whether this would ever
be re-introduced.

> My vote is not to drop the "free" kernel support, though I'm also not
> offering to take over maintenance so it probably doesn't count for
> much.

"Freeze" is pretty much where it has been for a while.  This thread was
started by a patch that caught up all the missing x86 system calls. Even
though the handlers all point into generic code, I'm always a bit twitchy
about including code that hasn't been exercised even once.  This would be
a lot easier if people adding system calls provided at least an example
program that uses the call ... even better would be an actual test-suite
that runs through all the options and failure cases for the call.  But
the recent slew of new syscalls have mostly lacked any such trimmings.

-Tony
