From: Dean Nelson <dcn@sgi.com>
Date: Mon, 20 Dec 2004 18:45:48 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20041220184548.GA23346@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 24, 2004 at 08:17:33PM +0100, Christoph Hellwig wrote:
> On Tue, Aug 24, 2004 at 01:23:44PM -0500, Dean Nelson wrote:
> > This patch contains the shim module (XP) which interfaces between the
> > communication module (XPC) and the functional support modules (like XPNET).
> > 
> is to have all three enabled at the same time.  Also as I mentioned previously
> please merge at least xp and xpc into a single module.
> 

As mentioned in the prologue to this series of patches having XP separate
from XPC has proven invaluable for debugging, which I'm guessing is not
a big selling point for you. But the main reason why we created it was
for XPMEM.

XPMEM, like XPNET, is a user of XPC and provides the ability to share
memory between processes on different partitions. It also provides the
ability for processes within the same partition to share memory.

XPMEM now carries the GNU General Public License. (You can find the source
at bonnie.engr.sgi.com:/proj/sgilinux/stout/isms/opensource/xpmem. This
source has been shipped to some customers as part of a BETA test program
and will be generally available with the next release of ProPack.) We are
planning to push XPMEM to the community as soon as we can find the time to
do so. (Note that it suffers from a number of the same 'issues' that were
raised about XP[C|NET], and we plan on addressing these before the initial
submission.)

Having the XP module separate from XPC allows for XPC to come and go
as needed without disturbing XPMEM and its users. This allows a site to
run a particular partition in isolation for a time (XPC not loaded) and
then open it up to the other partitions (XPC loaded).

In light of the above I would like to keep XP and XPC as separate modules.

Thanks,
Dean

