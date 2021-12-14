From: Matthew Wilcox <willy@infradead.org>
Date: Tue, 14 Dec 2021 13:14:48 +0000
Subject: Re: [PATCH v2 0/2] kdump: simplify code
Message-Id: <YbiYyDRW9aB9jFMD@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1639193588-7027-1-git-send-email-yangtiezhu@loongson.cn>
 <0c5cb37139af4f3e85cc2c5115d7d006@AcuMS.aculab.com>
 <YbXhVxRJfjvKw++W@casper.infradead.org>
 <b7a75ae9253445af81ff2fedd5268af4@AcuMS.aculab.com>
 <YbdcKK3Cq6ITTg/l@casper.infradead.org>
 <36440c0f-8b8a-c401-684f-6f54ce9c061e@loongson.cn>
In-Reply-To: <36440c0f-8b8a-c401-684f-6f54ce9c061e@loongson.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tiezhu Yang <yangtiezhu@loongson.cn>
Cc: David Laight <David.Laight@aculab.com>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Xuefeng Li <lixuefeng@loongson.cn>, Christophe Leroy <christophe.leroy@csgroup.eu>

On Tue, Dec 14, 2021 at 06:03:11PM +0800, Tiezhu Yang wrote:
> On 12/13/2021 10:43 PM, Matthew Wilcox wrote:
> > On Mon, Dec 13, 2021 at 08:30:33AM +0000, David Laight wrote:
> > > From: Matthew Wilcox
> > > > Sent: 12 December 2021 11:48
> > > > 
> > > > On Sat, Dec 11, 2021 at 05:53:46PM +0000, David Laight wrote:
> > > > > From: Tiezhu Yang
> > > > > > Sent: 11 December 2021 03:33
> > > > > > 
> > > > > > v2:
> > > > > >   -- add copy_to_user_or_kernel() in lib/usercopy.c
> > > > > >   -- define userbuf as bool type
> > > > > 
> > > > > Instead of having a flag to indicate whether the buffer is user or kernel,
> > > > > would it be better to have two separate buffer pointers.
> > > > > One for a user space buffer, the other for a kernel space buffer.
> > > > > Exactly one of the buffers should always be NULL.
> > > > 
> > > > No.  You should be using an iov_iter instead.  See
> > > > https://lore.kernel.org/all/Ya4bdB0UBJCZhUSo@casper.infradead.org/
> > > > for a start on this.
> > > 
> > > iov_iter gets horribly expensive...
> > 
> > Oh, right.  Reading the kcore is a high-performance path, my mistake.
> > 
> 
> Hi,
> 
> Thank you for your discussions.
> 
> The intention of this patchset is to simplify the related code with no
> functional changes and no side effects.
> 
> At this moment, if you are OK, I will send v3 used with inline function
> copy_to_user_or_kernel() to keep it simple, maybe other more changes can
> be done in the future if no any side effect.

That would be pointless.  I already sent a series to remove this,
which you were cc'd on.
