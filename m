From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 04 Jul 2007 16:58:06 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <20070705015806.6a82463f.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468BADA6.9050609@bull.net>
In-Reply-To: <468BADA6.9050609@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 04 Jul 2007 16:24:38 +0200
Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:
> Machines star up whit bit 5 = 0, reading instruction pages via
> NFS has to flush them from L2I.
> 
In our test, we confirmed that this can be fixed by flushing L2I just before 
SetPageUptodate() in NFS.

> 
> I was wondering if instead of modifying do_no_page() and Co., should
> not we make nfs_readpage() be DMA-like?
> (No possible regression for most of the page I/O-s.)
> I.e. it should be the responsibility of a file system to make sure it
> supports instruction pages correctly. The base kernel should provide
> such file systems with an architecture dependent macro...
> 
IMHO, for example, race in cooy-on-write  (was fixed by Tony Luck) has to be
fixed by MemoryManagement layer.
And only a race in do_no_page() seems to be able to be fixed by FS layer.

BTW, can we know whether a page is filled by DMA or not  ?

Thanks,
-Kame

