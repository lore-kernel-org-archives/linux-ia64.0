From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 18 Aug 2005 23:14:56 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <17157.5744.27263.526376@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> The simulator is not using the regular memcpy() routine it
Stephane> has its own custom routine (which is not named memcpy).

This is a stupid suggestion, but...

     Can you try recompiling the simulator with gcc 4.0, and see if
     the problem is still there?  If a gcc 4.0-compiled simulator that
     fixes the problem, and still allows booting of kernels compiled
     with icc, gcc-2.96, etc., etc., can be released, then we're done.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
