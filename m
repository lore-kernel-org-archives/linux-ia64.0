From: Russ Anderson <rja@sgi.com>
Date: Fri, 04 Mar 2005 18:44:50 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <200503041844.j24IioKM11229235@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Back on February 9th, I wrote:
> >I wrote a test program that loads up random values into registers
> >(just r1-r31, a bunch of stacked registers, and f2-f127 for now)
> >and then checks that all the registers haven't changed value a
> >few thousand times, before reloading with a new set of random
> >values.
> 
> A few people asked whether I could post the program ... it took
> a while to get sign-off ... but that gave me time to add "branch",
> "predicate" and half a dozen "application" registers to the mix,
> plus make it print the name of the register that was nuked (instead
> of a number that required manual translation).
> 
> I've tested it by using a debugger to zap one of each class of register
> that is being monitored to check that it works.
> 
> http://www.kernel.org/pub/linux/kernel/people/aegl/ia64regcheck.tgz 
> 
> Usage ... compile, and run a few copies.  If they all "exit(0)" (which
> may take a couple of days) the test passed.  Otherwise you should see
> the name of the register printed to stderr, and exit code 1.
> 
> Apart from the MCA case, I haven't seen it report a problem yet ... but
> I've only run a few hours.

I've started running multiple copies of checker with the error injection
code and so far none have indicated any errors on Altix systems.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
