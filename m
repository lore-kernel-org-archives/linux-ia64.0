From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Feb 2006 18:07:28 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <200602011807.k11I7ag15563@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060201180237.GA18464@infradead.org>
References: <20060126032918.GB9984@miraclelinux.com>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Hellwig' <hch@infradead.org>
Cc: 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Christoph Hellwig wrote on Wednesday, February 01, 2006 10:03 AM
> > Akinobu Mita wrote on Wednesday, January 25, 2006 7:29 PM
> > > This patch introduces the C-language equivalents of the functions below:
> > > 
> > > - atomic operation:
> > > void set_bit(int nr, volatile unsigned long *addr);
> > > void clear_bit(int nr, volatile unsigned long *addr);
> > > void change_bit(int nr, volatile unsigned long *addr);
> > > int test_and_set_bit(int nr, volatile unsigned long *addr);
> > > int test_and_clear_bit(int nr, volatile unsigned long *addr);
> > > int test_and_change_bit(int nr, volatile unsigned long *addr);
> > 
> > I wonder why you did not make these functions take volatile
> > unsigned int * address argument?
> 
> Because they are defined to operate on arrays of unsigned long

I think these should be defined to operate on arrays of unsigned int.
Bit is a bit, no matter how many byte you load (8/16/32/64), you can
only operate on just one bit.

- Ken

