From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 26 Jan 2006 19:54:59 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05892395@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> > +	while (unlikely((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val))
>> 80 COLUMNS.
>
>Again, tell me how to split this such that it fits in 80 and I'll gladly
>do it.  I don't see it.

Perhaps "SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK" is just a bit too
verbose/descriptive?  44 characters in a name is just asking for problems
in an 80 column environment.

-Tony

Longest symbol in the kernel sources has you beat by a long way though:

ZORRO_PROD_PHASE5_BLIZZARD_1230_II_FASTLANE_Z3_CYBERSCSI_CYBERSTORM060
