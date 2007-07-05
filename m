From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 05 Jul 2007 08:57:00 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <468CB25C.2040505@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <468BADA6.9050609@bull.net> <20070705015806.6a82463f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070705015806.6a82463f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 04 Jul 2007 16:24:38 +0200
> Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:
> 
>>Machines star up whit bit 5 = 0, reading instruction pages via
>>NFS has to flush them from L2I.
>>
> 
> In our test, we confirmed that this can be fixed by flushing L2I just before 
> SetPageUptodate() in NFS.

I can agree.
We can be more permissive: it can be done anywhere after the new
data is put in place and before nfs_readpage() or nfs_readpages()
returns.

I saw your patch http://marc.info/?l=linux-mm&m8352909826277&w=2
that modifies e.g. mm/memory.c and not the NFS layer.

Have you proposed a patch against the NFS layer?

>>I was wondering if instead of modifying do_no_page() and Co., should
>>not we make nfs_readpage() be DMA-like?
>>(No possible regression for most of the page I/O-s.)
>>I.e. it should be the responsibility of a file system to make sure it
>>supports instruction pages correctly. The base kernel should provide
>>such file systems with an architecture dependent macro...
>>
> 
> IMHO, for example, race in cooy-on-write  (was fixed by Tony Luck) has to be
> fixed by MemoryManagement layer.

I can agree.
Note that it has not got much performance impact from our point
of view because there are not too many COW paves with executable code...

> And only a race in do_no_page() seems to be able to be fixed by FS layer.

If it were do_no_page() that would fix the problem, then it should know
where the page comes from in order not to flush the I-cache in vain.
do_no_page() just calls vma->vm_ops->nopage() that goes down to
fs_op->readpage() / fs_op->readpages().

On the other hand, these latter routines do not know why they fetch
the page(s). Note that a page can be mapped more than one times, with
different permission bits.
As a consequence, these routines will flush the I-cache in vain in
most of the cases.

I prefer a performance impact to some non DMA based file systems
and adding nothing to the path for the majority of the cases.

> BTW, can we know whether a page is filled by DMA or not  ?

Well, the file systems based on block devices use DMA transfer
(with the exception of using bounce buffers, in that case it is the
responsibility of the bounce buffering layer to flush the I-cache).

Network based file systems require revision and update...

Note that only the processors with separate L2I require
attention, the L1I is guaranteed to be flushed when you change
the corresponding TBL entry.

The base kernel should provide a macro / service (that cares for the
processor model) for the file systems.

Thanks,

Zoltan Menyhart
