From: Steffen Persvold <sp@scali.com>
Date: Sun, 09 Jun 2002 10:34:26 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.18)
Message-Id: <marc-linux-ia64-105590701905656@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 7 Jun 2002, Bjorn Helgaas wrote:

> > 	-- With CONFIG_GENERIC, sba_iommu.c still doesn't compile
> > 	because of the removal of the address field from the scatterlist.
>
> Here's a patch to make sba_iommu work again.
>
> I added dma_address and dma_length to struct scatterlist and
> removed orig_address.  This brings IA64 in line with most other
> architectures, but required a few changes to swiotlb.
>
> Grant Grundler did the sba_iommu.c updates.
>
> Note that this isn't *quite* enough to make the generic kernel
> work on ZX1 boxes, because the ACPI in 2.5.18 barfs on a
> ZX1 _CRS method.
>
> David, I've tested both the swiotlb (on i2000 and ZX1) and
> sba_iommu (on ZX1, with a kludge for the ACPI problem),
> and they seem to work fine.

Hi Bjorn,

Do you have any estimate when this kludge for the ACPI problem on ZX1 is
available to the public ? Do the DIG version work on ZX1 now, or does
it barf on the same ACPI problem ?

Regards,
--
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


