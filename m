From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Aug 2005 20:19:38 +0000
Subject: RE: [PATCH 05/15] ia64: remove use of asm/segment.h
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F043851AD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0508241152380.23956@nylon.am.freescale.net>
In-Reply-To: <Pine.LNX.4.61.0508241152380.23956@nylon.am.freescale.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, Kumar Gala <galak@freescale.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org

>There are still a few drivers that include asm/segment.h, so
>I don't think we should remove asm/segment.h itself just yet.

Agreed.  The sequence should be to send patches to get rid of
all "#include <asm/segment.h>" references.

Once they have all gone, then a patch can remove the files.

If you are concerned that people would start adding new
references and you don't want to get into a game of whack-a-mole,
then you could add #warning "include of deprecated asm/segment.h",
but that might be overkill.

I'll apply this for ia64 w/o the deletion.

-Tony
