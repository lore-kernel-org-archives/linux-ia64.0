From: Grant Grundler <iod00d@hp.com>
Date: Wed, 01 Feb 2006 19:39:33 +0000
Subject: Re: [PATCH 1/12] generic *_bit()
Message-Id: <20060201193933.GA16471@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201180237.GA18464@infradead.org> <200602011807.k11I7ag15563@unix-os.sc.intel.com>
In-Reply-To: <200602011807.k11I7ag15563@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Grant Grundler <iod00d@hp.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, Feb 01, 2006 at 10:07:28AM -0800, Chen, Kenneth W wrote:
> I think these should be defined to operate on arrays of unsigned int.
> Bit is a bit, no matter how many byte you load (8/16/32/64), you can
> only operate on just one bit.

Well, if it doesn't matter, why is unsigned int better?

unsigned long is typically the native register size, right?
I'd expect that to be more efficient on most arches.

grant
