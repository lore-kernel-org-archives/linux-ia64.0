From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 22 Jan 2005 02:20:51 +0000
Subject: RE: optimize __gp location
Message-Id: <200501220220.j0M2Kpg03376@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote on Friday, January 21, 2005 5:03 PM
> >-  __gp = ADDR(.got) + 0x200000;
> >+  __gp = _end - 0x200000;
>
> Did we used to link the ".got" section earlier?  It's after "data" now,
> but the expression used there might have made sense if ".got" was before
> the "data".
>
> _end - 0x200000 may work for you now, but won't this be very configuration
> dependent?  If I configure lots of drivers with "=y" option, and they
> declare lots of "bss" objects, then __gp may still be too high to reach the
> interesting data objects.
>
> Would an expression anchoring on the ".sdata" section be better?

I wish I can do that.  But I'm frustrated that __gp is jailed in between
GOT section and the linker symbol _end.  There are references to _end from a
couple of functions like reserve_memory(), mem_init() that compiler insist on
using gp relative to calculate value of _end.

- Ken


