From: Tony Luck <tony.luck@intel.com>
Date: Thu, 24 Jun 2010 22:08:27 +0000
Subject: Re: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11 ia64)
Message-Id: <AANLkTinT8YMKGw3obdbIMINkUGNUgfUQEOEzgHMOPOtt@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201006242333018701088@tom.com>
In-Reply-To: <201006242333018701088@tom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bob_zhang2004 <bob_zhang2004@tom.com>
Cc: "len.brown" <len.brown@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

2010/6/24 bob_zhang2004 <bob_zhang2004@tom.com>:
> thanks much for comments, any idea is welcome!

Does this problem also appear in SLES11-SP1 ... which moved to
kernel version 2.6.32, and thus includes some changes to

drivers/acpi/acpica/hwsleep.c

Nothing obviously looks like it would cause this problem,
but it would be nice to know if the problem has already
been fixed.

-Tony
