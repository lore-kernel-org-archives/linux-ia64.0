From: Matt_Domsch@Dell.com
Date: Mon, 13 Oct 2003 15:37:50 +0000
Subject: Re: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106605963631800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106588409310269@msgid-missing>
In-Reply-To: <marc-linux-ia64-106588409310269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2003-10-13 at 10:21, John Levon wrote:
> On Mon, Oct 13, 2003 at 10:00:47AM +0100, Christoph Hellwig wrote:
> 
> > > > +       bool "EFI GUID Partition support" if PARTITION_ADVANCED
> > > > +       default y if !PARTITION_ADVANCED && IA64
> > > 
> > > Can we make CONFIG_LBD force on CONFIG_EFI_PARTITION too then?
> > 
> > I know the LBD backport is used with SGI disklabels in production
> > enviroments.  In fact that's the only production use I know of at
> all...
> 
> Besides, unless I'm missing something, current 2.6 doesn't prompt for
> LBD for IA64 at all ?
> 
> So, anybody want the patch :)

Actually, CONFIG_LBD is not necessary on IA-64.

include/linux/types.h:

 * The type used for indexing onto a disc or disc partition.
 * If required, asm/types.h can override it and define
 * HAVE_SECTOR_T
 */
#ifndef HAVE_SECTOR_T
typedef unsigned long sector_t;
#endif

Since HAVE_SECTOR_T isn't ever defined by IA-64, this does the right
thing.


-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

