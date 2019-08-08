From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Aug 2019 18:01:30 +0000
Subject: Re: remove sn2, hpsim and ia64 machvecs
Message-Id: <20190808180129.GA18553@agluck-desk2.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
 <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com>
 <3908561D78D1C84285E8C5FCA982C28F7F4143CB@ORSMSX115.amr.corp.intel.com>
 <20190807230737.GA11458@agluck-desk2.amr.corp.intel.com>
 <20190808065123.GA29146@lst.de>
In-Reply-To: <20190808065123.GA29146@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch@lst.de>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

On Thu, Aug 08, 2019 at 08:51:23AM +0200, 'Christoph Hellwig' wrote:
> On Wed, Aug 07, 2019 at 04:07:37PM -0700, Luck, Tony wrote:
> > On Wed, Aug 07, 2019 at 01:26:17PM -0700, Luck, Tony wrote:
> > > Ugh! The rule to do the compression was in arch/ia64/hp/sim/boot/Makefile
> > > which went away as part of the deletion of hpsim.
> > 
> > This fixes it ... should fold into the patch that dropped the
> > arch/ia64/hp/sim/boot/Makefile
> > 
> > I just cut/pasted in those cmd_gzip and cmd_objcopy definitions
> > from elsewhere in the tree. It might be possible to simplify them.
> 
> Lets keep it simple.  I've picked this up for the hpsim removal patch.

So most configs now build, and the generic one boots on my Tukwila system.

But a config based on arch/ia64/configs/zx1_defconfig gets a bunch
of build errors from different files complaining about 'max_mapnr'

arch/ia64/mm/init.c:198:8: error: 'max_mapnr' undeclared (first use in this function) 
./include/linux/dma-mapping.h:359:6: error: 'max_mapnr' undeclared (first use in this function)
kernel/dma/mapping.c:126:8: error: 'max_mapnr' undeclared (first use in this function)
kernel/dma/mapping.c:181:8: error: 'max_mapnr' undeclared (first use in this function)
mm/internal.h:393:8: error: 'max_mapnr' undeclared (first use in this function)

-Tony
