From: Christopher Wedgwood <cw@sgi.com>
Date: Wed, 30 Jul 2003 00:02:06 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952342323620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 06:56:15PM -0500, Jack Steiner wrote:

> If granularity is bytes, we need to support page-aligned
> allocations. Fetchop pages are mmap'ed to user space.

We could insist the allocator always return naturally aligned
allocations --- a page-size allocation will be page-aligned.  The only
kicker here is that someone wishing to allocate a large chunk of UC
space might get a failure where they otherwise would not.


  --cw
