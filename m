From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Dec 2004 21:47:49 +0000
Subject: RE: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02882DB7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
In-Reply-To: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Maybe I need to startup a pair of 2.6.11 trees?
>
>If it's not too much trouble...

I set up the test tree (linux-ia64-test-2.6.11) and dropped a
few of the pending patches into it.  I didn't even build it yet,
but I did just push it up the hill to bkbits.net.

Russ: Can you look again at efi.c ... just duplicating the whole
of efi_map_pal_code() and changing the last couple of lines to
switch from calling ia64_itr() to saving the address looks really
bad.  Can you extract all the duplicated code into a helper function
that each of efi_map_pal_code() and efi_get_pal_addr() can call.

I also still see a change in discontig.c that doesn't appear at
first glance to have a matching piece of code for the DISCONTIG=n
case (but I only glanced, so I might have missed it).

-Tony
