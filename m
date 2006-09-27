From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Sep 2006 23:49:03 +0000
Subject: RE: sysctl calls from userland
Message-Id: <617E1C2C70743745A92448908E030B2A96AABE@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A96AA90@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A96AA90@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> _sysctl(0x60000ffffe97f3c0)           = 0

Of course if I ran this on the machine running the *new* kernel it
would be more obvious what is happening:

_sysctl(0x60000fffff88f750)             = -1 ENOSYS (Function not implemented)
open("/proc/sys/kernel/version", O_RDONLY) = 3

So this is actually pretty harmless, except for the noise when
this happens the first five times.

-Tony
