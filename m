From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Date: Wed, 14 Feb 2007 03:26:18 +0000
Subject: Re: [Fedora-ia64-list] [PATCH] ide controller quirk to correct bad
Message-Id: <1171423578.2978.44.camel@ymzhang>
List-Id: <linux-ia64.vger.kernel.org>
References: <45D1DE90.9080709@redhat.com>
In-Reply-To: <45D1DE90.9080709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2007-02-13 at 10:51 -0500, Prarit Bhargava wrote:
> 
> Zhang, Yanmin wrote:
> > If ide controllers are at legacy mode, only the 4th BAR
> > is needed, so some BIOS initiate other BAR with incorrect
> > value. ata/ata_piix calls pci_enable_device on the ide
> > controller, which will check BAR resources. If the BAR
> > resource values are incorrect, pci_enable_device will fail,
> > and ata/ata_piix couldn't attach the ide controller.
> >
> > Below patch against 2.6.20 creates a quirk to correct the
> > bad BAR resources for a special ide controller which is
> > popular on tiger-4.
> >
> >   
> 
> If I understand the use of quirks, it is to fix hardware issues that 
> cannot be resolved by bios fixes, etc..  ie) real HW problems.  At least 
> that's been my feeble understanding.  If I'm wrong on that please 
> correct me.
Correct.

Curent issue of ide controller also could be considered as ide hardware
issue. If the ide controller is at legacy mode, bar 4 is enough, but
my ide controller provides bar 5 as well as 4. If the controller
hardwires bar 5 as 0, there will be no such issue.

> 
> Putting this sort of fix in opens up the kernel to resolving many 
> vendors' bios issues within the kernel.
> 
> I do understand that this is a special case -- it is unlikely a new bios 
> will ship for this box.  The way I see it, a future user of this 
> platform will have to build kernels that use the old ide-cd/piix driver 
> and/or patch the specific OS they are using with this patch.
From Alan's reply on linux-ide maillist, we could know another platform
PowerPC has the similiar issue. It assumes the BAR is not used if it is equal
to 0.

From the comments of function ide_pci_enable of the old ide driver, we could
see that such issue is not rare.

Is it better to put the patch into upstream kernel?

Yanmin
