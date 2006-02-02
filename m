From: Paul Mackerras <paulus@samba.org>
Date: Thu, 02 Feb 2006 22:43:50 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <17378.35622.918387.596756@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201180237.GA18464@infradead.org>
	<200602011807.k11I7ag15563@unix-os.sc.intel.com>
In-Reply-To: <200602011807.k11I7ag15563@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Chen, Kenneth W writes:

> Christoph Hellwig wrote on Wednesday, February 01, 2006 10:03 AM
> > Because they are defined to operate on arrays of unsigned long
> 
> I think these should be defined to operate on arrays of unsigned int.
> Bit is a bit, no matter how many byte you load (8/16/32/64), you can
> only operate on just one bit.

Christoph is right.  Changing to unsigned int would change the layout
on big-endian 64-bit platforms.

Paul.
