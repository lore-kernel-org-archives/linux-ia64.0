From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 05 Oct 2004 19:15:32 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041005191532.GB16153@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F0221C647@scsmsx401.amr.corp.intel.com> <200410050843.44265.jbarnes@engr.sgi.com> <20041005162201.GC18567@cup.hp.com> <20041005174558.GZ16153@parcelfarce.linux.theplanet.co.uk> <20041005191008.GG18567@cup.hp.com>
In-Reply-To: <20041005191008.GG18567@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Jesse Barnes <jbarnes@engr.sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Pat Gefre <pfg@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Oct 05, 2004 at 12:10:08PM -0700, Grant Grundler wrote:
> > > Maybe rename pci_root_ops to "acpi_pci_ops" would make that clearer.
> > 
> > No.  Don't rename it to anything ACPI specific.  It isn't.
> 
> I understand raw_pci_ops is not ACPI specific.
> But pci_root_ops is only used by pci_acpi_scan_root().

Yes, but if we had other ways of discovering PCI root bridges on ia64,
we would use it there too.  It's exactly the same as the i386 code which
has 7 different ways to discover PCI root bridges.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
