From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 23:54:05 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952294523287@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 06:49:04PM -0500, Jack Steiner wrote:

> True, but on NUMA systems (at least ours) you want MINSTATE area to
> be node local for other reasons. Some types of errors cause the
> interconnect to fail.

I think that's a slightly different issue but related.  Being able to
avoid any platform specific code here would be good thing and should
be possible if we are given a cpu/nodeid in the allocator.

> The PAL/SAL should be able to log errors without making offnode
> references.

The question then is are these areas as used by the kernel going to be
referenced globally or only on a cpu/node local sense?  Tony?


  --cw
