From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 May 2003 07:35:37 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705894@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 06:24:21PM -0500, James Bottomley wrote:
> On Thu, 2003-05-15 at 17:44, Colin Ngam wrote:
> > However, in PCI-X mode, we do not have the capability to generate SAC addresses.
> > And yes, you are also correct that it is very much efficient on our architecture
> > to generate DAC for all(PCI/PCI-X)
> > 
> > So, it is a hard requirement to have DAC for PCI-X devices and not PCI devices.
> > 
> > Hope that is clear ..
> 
> Actually, no.  This seems to imply that your PCI-X cards can *never*
> access the first 4GB of memory (because they can't use an IOMMU and they
> have to generate a DAC cycle with non zero in bits 63--32).
> 
> James

I don't know if it was clear or not in the ensuing replies, but we
don't present direct physical addresses to PCI-X cards.  Instead it's an
physical address with various bits ORed in at the top to set routing
and attribute information.  So if you want to DMA to physical address
0x1000 in the system, the PCI address might be 0x9100000000001000.

If it was already clear, sorry for the duplication.

jeremy

