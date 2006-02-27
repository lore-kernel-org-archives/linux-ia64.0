From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Feb 2006 19:18:34 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05CE60FC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think consistency with other arch is a better choice.  My vote would be
> index it from 0.

How do the applications that read this handle the levels ... I'd expect that a
well written application wouldn't care whether you indexed "C" style from 0
or "Fortran" style from 1 ... just so long as you provided some sanity that
lower numbered levels are closer to the cpu, and bigger numbers are further
away.

Are there any applications that look at /sys/devices/system/cpu/cpu*/cache*?

This like it might require some care to get right (different architectures providing
from 0 (unreported) to 3 (or more?) levels of cache ... with split/unified options
all over the map at each level.

-Tony
