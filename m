From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:54:18 +0000
Subject: Re: [Linux-ia64] 2.4.16-ia64-011128 is missing dma64_addr_t
Message-Id: <marc-linux-ia64-105590698805598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805568@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805568@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Dec 2001 09:45:19 +0100, Christoph Hellwig <hch@caldera.de> said:

  Christoph> On Mon, Dec 03, 2001 at 11:34:28AM -0800, David Mosberger
  Christoph> wrote:
  >> This error appears to be due to a bug in the sym53c8xx_2 driver.
  >> Note that dma64_addr_t should be used only for the pci_dac_*
  >> interface, which I do not want to support on ia64 unless and
  >> until we absolutely have to (technically, there is no need for
  >> pci_dac_* on ia64 or x86).

  Christoph> IA64 should use instead of it's horrible iommu emulation.

Huh?  pci_dac_*() does not help you here at all.  pci_dac_*() is only
needed/useful for 64-bit platforms which use a dma_addr_t that is
smaller than 64 bits.  And even then is it needed only for drivers
that create tons of mappings.

	--david

