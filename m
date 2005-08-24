From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Aug 2005 21:42:44 +0000
Subject: RE: [PATCH 05/15] ia64: remove use of asm/segment.h
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04385372@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0508241152380.23956@nylon.am.freescale.net>
In-Reply-To: <Pine.LNX.4.61.0508241152380.23956@nylon.am.freescale.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kumar Gala <kumar.gala@freescale.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Gala Kumar K.-galak" <galak@freescale.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org

>> I'll apply this for ia64 w/o the deletion.

This is now in my test tree.  I will send to Linus soon after
2.6.13 is released.

>I've posted a patch before this to remove all non-architecture users  
>of asm/segment.h.
>
>http://www.ussg.iu.edu/hypermail/linux/kernel/0508.3/0099.html

Good.  After that gets I applied I will delete include/asm-ia64/segment.h

-Tony
