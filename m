From: Colin Ngam <cngam@sgi.com>
Date: Thu, 15 May 2003 23:25:54 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705857@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

James Bottomley wrote:

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

Actually, our system does not have Physical Memory Address smaller than
48Bits - give or take couple bits ...  Hence, 32Bits Mapped DMA address
maps to 48Bits System Physical Address.

64Bits Mapped DMA address maps directly to System Physical Memory
with Bits 63-49 containing transfer attributes like hardware support
for byte swapping .. if needed(e.g. Big Endian Cards).

Thanks.

colin

>
>
> James


