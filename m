From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Apr 2006 15:49:50 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061E0BF1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Unless I am mistaken, there is no purge observed.

The purge cases will be very, very rare.  You either need to be
swapping (so that pages are being stolen out from the process
in the middle of the trap handler), or to construct some special
multi-threaded test (where some threads are re-mapping pieces
of the shared virtual space while other threads are trying to
use those addresses!).  Even in this case the race window is
tiny ... so I'd be surprised to see any benchmark generate more
than a few such purges per hour.

>It is very much curious having so few dirty and i-access traps...

Agreed.  The numbers for dirty/i-access traps are very low (less
than one per invocation of gcc during a kernel build).

>Have you got some good & stressing tests?

Nothing comes to mind that would really stress this code.  Either
you need to make the system swap heavily (boot with mem8m, and
then run make -j32, or some such thing ... but some tuning would
be needed to get enough swapping but still make enough progess),
or create some custom multi-threaded test that does mapping &
unmapping (I'm not aware of any real application that does anything
like this ... threads would have to cope with occasional SIGSEGV
if they happened to make an access while the addresses were being
re-mapped).

-Tony
