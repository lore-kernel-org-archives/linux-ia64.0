From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Mar 2005 01:08:39 +0000
Subject: AGP causing instant crash on zx1-based systems
Message-Id: <200503290108.j2T18dWN010574@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave,

It appears that one of your (relatively) recent changes to
agp/generic.c is assuming that all AGP bridges are PCI devices.  You
may remember that this isn't the case for the zx1 AGP bridge (which is
an ACPI-described device).

In particular, I'm seeing crashes due to the call to
check_agp_bridgemode().  I suppose hp-agp.c could provide its own
versions of the "generic.c" functions which use this function but it
seems that would lead to lots of code duplication and would make
things more fragile.  Perhaps it's possible to put this info somewhere
in the agp_bridge_data so that each backend can initializat it on its
own?

Or did you have something else in mind here?

Thanks,

	--david
