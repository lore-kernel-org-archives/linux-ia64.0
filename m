From: Grant Grundler <iod00d@hp.com>
Date: Fri, 16 May 2003 18:23:41 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705906@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 11:47:55PM -0700, Jeremy Higdon wrote:
> Certainly all PCI-X devices should support
> 64 bit addresses for descriptors.

I finally found the bit in the PCI-X spec hat mentions this:
(Section 1.8 "Bus Width")
| The following PCI-X requirements are different from conventional PCI:
| 1. All devices that initiate memory transactions must be capable of
|    generating 64-bit addresses.
| 2. Each device includes a configuration status bit that indicates
|    the width of that device's interface.

PCI-X also has a different command set.
It's definitely NOT just a PCI bus speed up.

thanks,
grant

