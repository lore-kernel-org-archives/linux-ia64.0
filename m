From: "Moore, Robert" <robert.moore@intel.com>
Date: Mon, 13 Sep 2004 19:37:52 +0000
Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <37F890616C995246BE76B3E6B2DBE05501FB467C@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095103349.2512.16.camel@d845pe>
In-Reply-To: <1095103349.2512.16.camel@d845pe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Brown, Len" <len.brown@intel.com>, Alex Williamson <alex.williamson@hp.com>
Cc: linux-ia64@vger.kernel.org, ACPI Developers <acpi-devel@lists.sourceforge.net>

I agree with what Len has written.

Not only is the !Windows code path apparently untested for the most
part, we have discovered many machines that simply do not work properly
unless we report "Microsoft Windows NT" for the _OS string.  This is
another reason why we changed this string from "Linux"

Bob


> -----Original Message-----
> From: acpi-devel-admin@lists.sourceforge.net [mailto:acpi-devel-
> admin@lists.sourceforge.net] On Behalf Of Len Brown
> Sent: Monday, September 13, 2004 12:23 PM
> To: Alex Williamson
> Cc: linux-ia64@vger.kernel.org; ACPI Developers
> Subject: Re: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
> 
> On Mon, 2004-09-13 at 14:27, Alex Williamson wrote:
> >    A recent change to ACPI made the _OS object falsely report the OS
as
> > "Microsoft Windows NT".  This seems like a slippery slope, and I'd
> > rather not go down it for ia64.  I think all of the ia64 OEMs are
> > involved enough with Linux that this isn't necessary and the change
> > limits the options should ACPI firmware need to make an OS specific
work
> > around.  The patch below will make all ia64 boxes report a default
_OS
> > of "Linux".
> 
> While I share your pride in Linux, there are a couple of reasons
> why we do not make _OS return "Linux".
> 
> _OS is a deprecated interface -- it has been replaced
> by the more flexible _OSI.  So with _OS we're talking
> about past, not future systems.  And there is a total
> population of 0 systems in the installed base that check
> for _OS ="Linux" in their firmware.  On the other hand, there
> are zillions of systems that check for Windows with _OS,
> and the !Windows path through the firmware is effectivly
> unvalidated.
> 
> While this is really important on i386, it may not be
> important for ia64.  However, unless you can show
> me an existing system that checks for _OS=Linux, then
> it only adds risk w/o reward to make this change, even
> if just on ia64.  New systems should be using _OSI.
> 
> thanks,
> -Len
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
> Project Admins to receive an Apple iPod Mini FREE for your judgement
on
> who ports your project to Linux PPC the best. Sponsored by IBM.
> Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
> _______________________________________________
> Acpi-devel mailing list
> Acpi-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/acpi-devel
