From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Tue, 02 Apr 2002 15:14:10 +0000
Subject: RE: [Linux-ia64] Basic Advice Needed
Message-Id: <marc-linux-ia64-105590701905362@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905348@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905348@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As someone pointed out, the network and SCSI adapters may be causing
> problems. It has an Adaptec Ultra160 dual channel SCSI card for
> example, which definitely seems nonstandard.

Yes, that card works well -- if you have the right driver.

Use the latest Adaptec driver from Justin Gibbs.  There was a bug in the
early 39-bit DMA support that caused the kernel to crash periodically
[if the address just happened to overlab the swiotlb in the low 32 bits].

He incorporated my fix in Change 420:
http://people.freebsd.org/~gibbs/linux/

If you want to see if that affects you, look at the call to
pci_unmap_single();
if the second parameter is:
   ahc_le32toh(scb->sg_list[0].addr),
you have the broken version.  Note that the 2.4.9 kernel has the broken
version,
and IA64 kernels before that didn't support 39-bit DMA (which leads to
problems
under load, unless you greatly increase swiotlb size).  Not sure what
version
is in the newer IA64 kernels.

Kevin

