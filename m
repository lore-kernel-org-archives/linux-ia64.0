From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jun 2006 00:09:47 +0000
Subject: RE: Question about the segment [[ 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 ]]
Message-Id: <617E1C2C70743745A92448908E030B2A0EE673@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 60000fff80000000-60000fff80004000 rw-p 0000000000000000 00:00 0 (just
> above the stack).

RSE backing store.

> Also why IPF kernel differs from other systems where the mmap space is
> below &_etext where as on other systems its above &_end. ??

Do you have an application where this is a problem?

-Tony
