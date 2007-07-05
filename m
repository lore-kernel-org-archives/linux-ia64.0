From: Mike Stroyan <mike@stroyan.net>
Date: Thu, 05 Jul 2007 17:36:21 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <20070705173621.GA8320@stroyan.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <468BADA6.9050609@bull.net> <20070705015806.6a82463f.kamezawa.hiroyu@jp.fujitsu.com> <468CB25C.2040505@bull.net>
In-Reply-To: <468CB25C.2040505@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 05, 2007 at 10:57:00AM +0200, Zoltan Menyhart wrote:
> KAMEZAWA Hiroyuki wrote:
> >In our test, we confirmed that this can be fixed by flushing L2I just 
> >before SetPageUptodate() in NFS.
> 
> I can agree.
> We can be more permissive: it can be done anywhere after the new
> data is put in place and before nfs_readpage() or nfs_readpages()
> returns.
> 
> I saw your patch http://marc.info/?l=linux-mm&m8352909826277&w=2
> that modifies e.g. mm/memory.c and not the NFS layer.
> 
> Have you proposed a patch against the NFS layer?

  This really doesn't look like a job for the file system layer.
That would require all sorts of file system readpage routines to
be modified to handle memory management details that are already
handled by the memory.c functions.  The do_no_page code is already
dealing with the necessary icache flushing operations.  It just
happens to be doing it with a bad race condition for ia64.

-- 
Mike Stroyan <mike@stroyan.net>
