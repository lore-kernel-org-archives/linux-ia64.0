From: Robin Holt <holt@sgi.com>
Date: Tue, 09 Dec 2008 11:13:14 +0000
Subject: Re: [Patch 4/4] Clear up section mismatch for ioc4_ide_attach_one.
Message-Id: <20081209111314.GF8970@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081208144346.959154466@attica.americas.sgi.com>
In-Reply-To: <20081208144346.959154466@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 08, 2008 at 03:50:06PM -0800, Luck, Tony wrote:
> > The generic_defconfig has three section mismatches.  This clears up
> > ioc4_ide_attach_one().
> 
> After applying this patch (and parts 2&3 too) I got a build error (using
> gcc 4.3.1 ... which I think is pickier about some of this section stuff):
> 
> drivers/ide/sgiioc4.c:533: error: sgiioc4_port_info causes a section type conflict
> 
> The declaration for this should really be using __devinitconst rather
> than __devinitdata.  I can fold a s/__devinitdata/__devinitconst/ patch
> into this one if that looks OK to you.

That would be wonderful.

Thank you,
Robin
