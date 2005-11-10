From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Nov 2005 23:03:16 +0000
Subject: RE: [Patch 1/1] 4-level page tables v4.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EE756A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
In-Reply-To: <20051110161915.GA3630@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Is the goal to make these identical?  If so, it should be easy to do,
>but I was not aware that was the intent.

Identical is only required if it can be proved that the
orginal was perfectly optimised to a unique peak point :-)

My post was just requesting David, Ken (and anyone else
who can schedule ia64 instructions in their head) to take
a look to make sure this isn't stalling someplace.

If the new code runs just as fast as the old, the only
possible remaining sticking point would be maintainability
of the code ... assembly code does not lend itself well
to the games we play in C code to keep the #ifdefs under
control.  You've added six new #ifdefs to the fifteen
already in ivt.S ... it was already hard to read (which
is why I resorted to compiling and diffing the dissassembly
to see what really changed).

-Tony
