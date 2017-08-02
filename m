From: Bjorn Helgaas <helgaas@kernel.org>
Date: Wed, 02 Aug 2017 20:00:31 +0000
Subject: Re: pci: Add generic pcibios_{fixup_bus,align_resource}
Message-Id: <20170802200031.GD20308@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170624015044.16746-1-palmer@dabbelt.com>
In-Reply-To: <20170624015044.16746-1-palmer@dabbelt.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, bhelgaas@google.com, hch@infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-snps-arc@lists.infradead.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Fri, Jun 23, 2017 at 06:50:41PM -0700, Palmer Dabbelt wrote:
> While upstreaming the RISC-V port, it was pointed out that multiple
> architectures have copied the mostly empty versions of at least one of these
> functions.  This defines weakly bound versions of the common functions and
> removes the now obselete functions from other ports.
> 
> This has been split out from the RISC-V submission so we can decouple all these
> generic changes from our port review process.  There's some discussion on an
> earlier version of the patch here
> 
>   https://lkml.org/lkml/2017/6/6/998
> 
> but I'm afraid a lot of this is really out of my wheelhouse (and I'm pretty
> slammed trying to get the RISC-V port in better shape), so I'm afraid I'm not
> going to be able to perform the full cleanup suggested.

Applied to pci/resource for v4.14, thanks!

There's room for future improvement, e.g., using per-host callbacks,
etc., but I think this is a clear improvement as-is.

There's some folklore about the evils of weak symbols, but I don't
know the details.  It would be useful to have them codified somewhere
in Documentation/ or near the __weak definition.
