From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Sep 2004 19:42:02 +0000
Subject: Re: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <1095104522.20631.54.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095100068.20631.30.camel@tdi>
	 <1095103349.2512.16.camel@d845pe>
In-Reply-To: <1095103349.2512.16.camel@d845pe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <len.brown@intel.com>
Cc: linux-ia64@vger.kernel.org, acpi-devel <acpi-devel@lists.sourceforge.net>

On Mon, 2004-09-13 at 15:22 -0400, Len Brown wrote:
> On Mon, 2004-09-13 at 14:27, Alex Williamson wrote:
> >    A recent change to ACPI made the _OS object falsely report the OS as
> > "Microsoft Windows NT".  This seems like a slippery slope, and I'd
> > rather not go down it for ia64.  I think all of the ia64 OEMs are
> > involved enough with Linux that this isn't necessary and the change
> > limits the options should ACPI firmware need to make an OS specific work
> > around.  The patch below will make all ia64 boxes report a default _OS
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

  Perhaps true for i386.  While I don't know of any ia64 AML that checks
_OS, I do know that we extensively test any !Windows path that exists...
or at least we did.

> While this is really important on i386, it may not be
> important for ia64.  However, unless you can show
> me an existing system that checks for _OS=Linux, then
> it only adds risk w/o reward to make this change, even
> if just on ia64.  New systems should be using _OSI.

   I see the risk in *changing* the _OS, but not in leaving it the way
it was.  SLES9 has already shipped based on 2.6.5.  That ACPI CA set the
_OS to "Linux".  Many platforms have gone through full certification on
that kernel.  How is it more risky to stay with "Linux"?  If it's a
deprecated interface, why change it at the end of it's life when there
are no known benefits on ia64?  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

