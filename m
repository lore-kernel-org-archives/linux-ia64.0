From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 Oct 2007 20:19:17 +0000
Subject: RE: driver to support ACPI AML calls to native firmware
Message-Id: <617E1C2C70743745A92448908E030B2A029DAE89@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200709201420.24023.bjorn.helgaas@hp.com> <200710051058.55141.bjorn.helgaas@hp.com>
In-Reply-To: <200710051058.55141.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org

> Ping!  Tony, can you let me know your plans for this patch?  I'd
> like to get it into a distro release, and of course, it's best if
> you accept it first.

I'll put it in soon.  My only vague concern is whether it should be more
accessible for other OEMs who want to do the SAL/ACPI sharing thing. But
I can wait and see whether we get a proliferation of OEM specific
drivers doing the same kind of thing.  If we do, then we'll look at how
to merge the common stuff.

-Tony
