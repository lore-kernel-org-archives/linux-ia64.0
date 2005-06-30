From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Jun 2005 17:23:56 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03D0BD34@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Matt Chapman found a work around for my problem with
>booting 2.6.12-mm2 on my rx2600. Basically it can boot in
>SMP mode, if we bypass some of the migration cost
>measurements using the command line option migration_cost
Interesting.

>Given that the same kernel boots on some other rx2600, it
>seems like there may be a timing bug/race in this code.
>Could your GIT bisect method identify a change in that 
>piece of code?

It's Linus' bisect method ... and it *might* be useful here if
you have a start point (where the bug definitely isn't present)
and end point (where it is).  Since we suspect a timing problem
though, it may not be very amenable to the bisection search as
other changes may tweak the timing enough to hide the problem
in some test ... which would send us along the wrong path in
the bisection :-(

Can you give more details of your workaound.  Did you make
any code changes, or did you just use the "migration_cost="
option?  What value did you provide?

-Tony
