From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Jan 2005 23:57:41 +0000
Subject: RE: INIT handler modification
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02AA1D0C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41DE990B.702@Ext.Bull.Net>
In-Reply-To: <41DE990B.702@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>You're right, this is a serious problem that needs to be fixed.
>Unfortunately, it's a little more complicated than the change
>you propose, because we need per-CPU areas (or locking) for
>saving the min-state areas from firmware.  I think the recent
>"per cpu MCA/INIT" changes are heading in this direction, so
>please take a look at those, try them out, and improve them!

There should be enough parts of Russ Anderson's changes in the
http://linux-ia64.bkbits.net/linux-ia64-test-2.6.11 tree to give
this a try.  It should also show up in the next -mm patch (it
missed 2.6.10-mm2).

You'd need to add some serialization in ia64_init_handler() and/or
init_handler_platform() to make sure that all the cpus didn't stomp
all over each other printing their registers, and you'll only want
one of them to walk the tasklist providing backtraces.

-Tony
