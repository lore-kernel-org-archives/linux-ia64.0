From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Feb 2006 19:25:25 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <200602011925.k11JPYg22845@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060201191957.GG3072@flint.arm.linux.org.uk>
References: <20060126032918.GB9984@miraclelinux.com>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Russell King' <rmk+lkml@arm.linux.org.uk>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Russell King wrote on Wednesday, February 01, 2006 11:20 AM
> > I think these should be defined to operate on arrays of unsigned int.
> > Bit is a bit, no matter how many byte you load (8/16/32/64), you can
> > only operate on just one bit.
> 
> Invalid assumption, from the point of view of endianness across different
> architectures.  Consider where bit 0 is for a LE and BE unsigned long *
> vs a LE and BE unsigned char *.

Where the bit end up in LE or BE is irrelevant. As long as one always
use the same bit numbering and same address pointer type, you always
get the same bit.  Or am I missing something?

- Ken

