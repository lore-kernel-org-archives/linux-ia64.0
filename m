From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 22:46:47 +0000
Subject: RE: Simulator bootloader fails with gcc 4
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F042946D2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>On Thu, Jul 21, 2005 at 11:00:56PM -0700, david mosberger wrote:
>> > http://gcc.gnu.org/bugzilla/show_bug.cgi?id"605
>
>> Dan, do you want to take a quick look to see if anything obvious is
>> wrong in that area?
>
>Did anyone end up deciding if the kernel or the simulator should be
>fixed?  I'd like the simulator autobuild to "just work" with gcc4
>without having to copy in an old bootloader or something.

And behind door number 3 is to fix the compiler ... but that also
seems to be contentious (and doesn't help people who are already
using gcc4).

Is the simulator in error by only half loading when the structure
is on a 4-byte boundary ... if so, then my 2nd choice would be to
fix it there.

But ... since the fix is small, I could put it into the kernel
as a last resort to get things working again.  Do you really need
to align(16)? Or would (8) do?  A comment mentioning that this
is a workaround for a compiler and/or simulator issue would be
good.

-Tony
