From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 22 Jan 2005 01:02:52 +0000
Subject: RE: optimize __gp location
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02C70ECA@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>-  __gp = ADDR(.got) + 0x200000;
>+  __gp = _end - 0x200000;

Did we used to link the ".got" section earlier?  It's after "data" now,
but the expression used there might have made sense if ".got" was before
the "data".

_end - 0x200000 may work for you now, but won't this be very configuration
dependent?  If I configure lots of drivers with "=y" option, and they
declare lots of "bss" objects, then __gp may still be too high to reach the
interesting data objects.

Would an expression anchoring on the ".sdata" section be better?

-Tony
