From: Grant Grundler <iod00d@hp.com>
Date: Mon, 19 May 2003 16:26:48 +0000
Subject: Re: [Linux-ia64] Re: [patch] support 64 bit pci_alloc_consistent
Message-Id: <marc-linux-ia64-105590723705945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 18, 2003 at 04:26:22PM -0500, James Bottomley wrote:
> A full bit u64 mask should never fail...

OK. "never fail" in the sense that the driver has advertised a mask
which equals or exceeds the platform capabilities. 

Bottom line is the driver has to check the platform DMA support
likes the proposed mask and adjust it's behavior accordingly.
Existing API and Arjen's proposal both require that.

> Also, knowing the effective mask (and it would have to be set properly
> on return) would be extremely useful for drivers that have weird width
> modes (like aic with 64 vs 39 vs 32 bit addressing in the
> descriptors)

aic driver could try all three in order of preference?
"extremely useful" seems like a stretch to me.

> ...it would allow me to eliminate the memory size checks in
> those drivers.

I expect DMA support to determine how many bits are needed to
address all of physical RAM and accept/reject the 64/39/32-bit DMA
mask as appropriate. I haven't studied x86 DMA support recently.
There might be valid reasons it doesn't work that way.

grant

