From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 16 May 2003 06:47:55 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 01:07:39PM -0700, David S. Miller wrote:
>    From: Colin Ngam <cngam@sgi.com>
>    Date: Thu, 15 May 2003 08:17:58 -0500
>    
>    Anyway, to make a long story short, we like to "extend" these
>    interfaces to return DMA addresses of 64 bits if and when the
>    driver has the full capabality to support DAC - via it's
>    DMA mask capability setting.
> 
> All devices I am aware of do not support 64-bit addresses for their
> descriptors, only 32-bit.

The Qlogic and LSI Logic SCSI and FC devices support 64 bit addresses
for their descriptors.  Also the old Adaptec (now JNI) 1160.  I do
not believe this is unusual.  Certainly all PCI-X devices should support
64 bit addresses for descriptors.

The Tigon3 supports 64 bit addresses for descriptors.

> There is a huge difference between using a "64-bit address" and
> requiring to generate a DAC cycle, the latter of which is
> probably what you need and that is independant of what kind of
> address pci_alloc_consistent() is giving you.

Not independent.  Because if pci_alloc_consistent gives an address
in which any of bits 32-63 are set, then the adapter will use a DAC
to access the descriptor.  I guess you're saying that some adapters
may support more than 32 bits but fewer than 64.  Such devices
would not work on our platform.  Which PCI-X devices do not support
the full 64 bit address space? I don't know of any.

jeremy

