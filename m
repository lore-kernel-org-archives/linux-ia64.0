From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Sat, 24 Jun 2017 01:50:41 +0000
Subject: pci: Add generic pcibios_{fixup_bus,align_resource}
Message-Id: <20170624015044.16746-1-palmer@dabbelt.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org

While upstreaming the RISC-V port, it was pointed out that multiple
architectures have copied the mostly empty versions of at least one of these
functions.  This defines weakly bound versions of the common functions and
removes the now obselete functions from other ports.

This has been split out from the RISC-V submission so we can decouple all these
generic changes from our port review process.  There's some discussion on an
earlier version of the patch here

  https://lkml.org/lkml/2017/6/6/998

but I'm afraid a lot of this is really out of my wheelhouse (and I'm pretty
slammed trying to get the RISC-V port in better shape), so I'm afraid I'm not
going to be able to perform the full cleanup suggested.

