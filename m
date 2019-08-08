From: 'Christoph Hellwig' <hch@lst.de>
Date: Thu, 08 Aug 2019 06:51:23 +0000
Subject: Re: remove sn2, hpsim and ia64 machvecs
Message-Id: <20190808065123.GA29146@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de> <3908561D78D1C84285E8C5FCA982C28F7F41388B@ORSMSX115.amr.corp.intel.com> <3908561D78D1C84285E8C5FCA982C28F7F4143CB@ORSMSX115.amr.corp.intel.com> <20190807230737.GA11458@agluck-desk2.amr.corp.intel.com>
In-Reply-To: <20190807230737.GA11458@agluck-desk2.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: 'Christoph Hellwig' <hch@lst.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>

On Wed, Aug 07, 2019 at 04:07:37PM -0700, Luck, Tony wrote:
> On Wed, Aug 07, 2019 at 01:26:17PM -0700, Luck, Tony wrote:
> > Ugh! The rule to do the compression was in arch/ia64/hp/sim/boot/Makefile
> > which went away as part of the deletion of hpsim.
> 
> This fixes it ... should fold into the patch that dropped the
> arch/ia64/hp/sim/boot/Makefile
> 
> I just cut/pasted in those cmd_gzip and cmd_objcopy definitions
> from elsewhere in the tree. It might be possible to simplify them.

Lets keep it simple.  I've picked this up for the hpsim removal patch.
