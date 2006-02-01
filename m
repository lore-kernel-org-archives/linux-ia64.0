From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Feb 2006 21:41:03 +0000
Subject: RE: [PATCH 1/12] generic *_bit()
Message-Id: <200602012141.k11LfCg32497@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060201193933.GA16471@esmail.cup.hp.com>
References: <20060126032918.GB9984@miraclelinux.com>
In-Reply-To: <20060126032918.GB9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Grant Grundler' <iod00d@hp.com>
Cc: 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Grant Grundler wrote on Wednesday, February 01, 2006 11:40 AM
> On Wed, Feb 01, 2006 at 10:07:28AM -0800, Chen, Kenneth W wrote:
> > I think these should be defined to operate on arrays of unsigned int.
> > Bit is a bit, no matter how many byte you load (8/16/32/64), you can
> > only operate on just one bit.
> 
> Well, if it doesn't matter, why is unsigned int better?


I was coming from the angle of having bitop operate on unsigned
int *, so people don't have to type cast or change bit flag variable
to unsigned long for various structures.  With unsigned int type for
bit flag, some of them are not even close to fully utilized. for example:

thread_info->flags uses 18 bits
thread_struct->flags uses 7 bits

It's a waste of memory to define a variable that kernel will *never*
touch the 4 MSB in that field.


> unsigned long is typically the native register size, right?
> I'd expect that to be more efficient on most arches.


The only difference that I can think of on Itanium processor is the
memory operation, you either load/store 4 or 8 bytes. Once the data
is in the CPU register, it doesn't make any difference whether it is
operating on 32bit or entire 64 bit. I don't know about others RISC
arch though whether it is more efficient with native register size.

- Ken

