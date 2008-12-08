From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Dec 2008 23:50:06 +0000
Subject: RE: [Patch 4/4] Clear up section mismatch for ioc4_ide_attach_one.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C77DB7E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081208144346.959154466@attica.americas.sgi.com>
In-Reply-To: <20081208144346.959154466@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The generic_defconfig has three section mismatches.  This clears up
> ioc4_ide_attach_one().

After applying this patch (and parts 2&3 too) I got a build error (using
gcc 4.3.1 ... which I think is pickier about some of this section stuff):

drivers/ide/sgiioc4.c:533: error: sgiioc4_port_info causes a section type conflict

The declaration for this should really be using __devinitconst rather
than __devinitdata.  I can fold a s/__devinitdata/__devinitconst/ patch
into this one if that looks OK to you.

-Tony
