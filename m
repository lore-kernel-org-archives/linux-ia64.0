From: Nate Lawson <nate@root.org>
Date: Mon, 13 Sep 2004 22:19:29 +0000
Subject: Re: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <41461CF1.1000104@root.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <37F890616C995246BE76B3E6B2DBE05501FB467C@orsmsx403.amr.corp.intel.com> <Pine.LNX.4.61.0409132325261.11103@lifschitz.suse.de>
In-Reply-To: <Pine.LNX.4.61.0409132325261.11103@lifschitz.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Gerald Pfeifer <gp@suse.de>
Cc: "Moore, Robert" <robert.moore@intel.com>, "Brown, Len" <len.brown@intel.com>, Alex Williamson <alex.williamson@hp.com>, linux-ia64@vger.kernel.org, ACPI Developers <acpi-devel@lists.sourceforge.net>

Gerald Pfeifer wrote:
> On Mon, 13 Sep 2004, Moore, Robert wrote:
> 
>>Not only is the !Windows code path apparently untested for the most 
>>part, we have discovered many machines that simply do not work properly 
>>unless we report "Microsoft Windows NT" for the _OS string.
> 
> Can you name some of these (broken) systems?
> 
> Given that we apparently did not encounter this with our 2.6.5-based SLES9 
> kernel so far, I'm a bit sceptical that many (if any) ia64 machines are 
> affected.

The only ones I've seen have been i386.  One was a broken irq routing 
mechanism in the !windows case.  It's likely the case that there are no 
broken ia64 machines.  But it's also likely that no ia64 systems read 
\_OS so why should it matter what we put there?  I agree with Len, if 
you need to key off something OS-specific for Linux, use \_OSI.

-- 
Nate
