From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 15 Sep 2004 15:35:16 +0000
Subject: RE: INIT dumps broken?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02051268@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
In-Reply-To: <200409141450.i8EEotfk029379@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Can anybody describe why cpu 0 changed from 0xe... to 0xa... for the
>idle task between 2.6.7-rc3 and 2.6.8?

Because the initialized lists in the init_task structure were all
messed up.  When we moved the kernel to region 5 we originally tried
to keep the task for proc 0 in region 7 ... so head.S converted from
the region 5 address that &init_task now gave us to a region 7 1:1
mapped address.  But the initialized list_head structures inside the
init_task used the region 5 addresses ... and this upset the other
list macros (e.g. the actually empty list didn't appear empty anymore
because it apparently didn't point to itself because of the mix of
region 5 and region 7 addresses.  There were a few patch attempts to
try any rescue the "address via region 7" solution, but the kernel is
now littered with "&init_task" references in generic code ... so we
changed head.S to drop the region5->region7 conversion.

I'll take a look at fixing the INIT code today.

-Tony
