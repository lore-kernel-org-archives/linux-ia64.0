From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 19 Oct 2003 11:25:37 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106656307124322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@osdl.org> writes:

> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >
> > >>>>> On Fri, 17 Oct 2003 16:55:43 -0700, Andrew Morton <akpm@osdl.org> said:
> > 
> >   >> If we really believe copy_*_user() must correctly handle *all* faults,
> >   >> isn't the "p >= __pa(high_memory)" test superfluous?
> > 
> > Andrew> This code was conceived before my time and I don't recall seeing much
> 
> >   Andrew> discussion, so this is all guesswork..
> > 
> >   Andrew> I'd say that the high_memory test _is_ superfluous and that
> >   Andrew> if anyone cared, we would remove it and establish a
> >   Andrew> temporary pte against the address if it was outside the
> >   Andrew> direct-mapped area.  But nobody cares enough to have done
> >   Andrew> anything about it.

This can be useful for the case of > 4GB on a 32bit box.  But for mmio
it is useless.

> > What about memory-mapped device registers?  Isn't all memory
> > physically contiguous on x86 and that's why the "p >> > __pa(high_memory)" test saves you from that?
> 
> We _want_ to be able to read mmio ranges via /dev/mem, don't we?  I guess
> it has never come up because everyone uses kmem.

No.

sys_read/sys_write does not give you enough control to write a device driver
from user space if you want to access something other than RAM you need to
mmap /dev/mem and issue the appropriate read/write commands.  

On ia64 you can send the variant that won't generate a machine check if it
fails.  You can get the alignment right etc, etc.  

And even if you can get the interface right from user space to make mmio
work through sys_read/sys_write it will still be slow and silly to use.
And since it is useless it will go unused and then regress in
strange peculiar unexpected ways.

We do have all of the information we need in struct page to see if a
page address is valid, so checking that is reasonable.  I suspect it
will require some interesting variant of pfn_to_page to handle of the
weird sparse memory locations properly.

Of course it might just be reasonable to require knowing and
responsible use of /dev/mem.  Whatever you are doing.

Eric
