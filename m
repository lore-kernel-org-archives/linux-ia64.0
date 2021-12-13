From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 13 Dec 2021 08:30:33 +0000
Subject: RE: [PATCH v2 0/2] kdump: simplify code
Message-Id: <b7a75ae9253445af81ff2fedd5268af4@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
 <0c5cb37139af4f3e85cc2c5115d7d006@AcuMS.aculab.com>
 <YbXhVxRJfjvKw++W@casper.infradead.org>
In-Reply-To: <YbXhVxRJfjvKw++W@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Matthew Wilcox' <willy@infradead.org>
Cc: 'Tiezhu Yang' <yangtiezhu@loongson.cn>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Xuefeng Li <lixuefeng@loongson.cn>

From: Matthew Wilcox
> Sent: 12 December 2021 11:48
> 
> On Sat, Dec 11, 2021 at 05:53:46PM +0000, David Laight wrote:
> > From: Tiezhu Yang
> > > Sent: 11 December 2021 03:33
> > >
> > > v2:
> > >   -- add copy_to_user_or_kernel() in lib/usercopy.c
> > >   -- define userbuf as bool type
> >
> > Instead of having a flag to indicate whether the buffer is user or kernel,
> > would it be better to have two separate buffer pointers.
> > One for a user space buffer, the other for a kernel space buffer.
> > Exactly one of the buffers should always be NULL.
> 
> No.  You should be using an iov_iter instead.  See
> https://lore.kernel.org/all/Ya4bdB0UBJCZhUSo@casper.infradead.org/
> for a start on this.

iov_iter gets horribly expensive...

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
