From: Jack Steiner <steiner@sgi.com>
Date: Tue, 29 Jul 2003 23:49:04 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952256122956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > 
> > We could like to be able to allocate from or near to a given node in
> > NUMA configurations.  When allocating pages for MINSTATE areas you can
> > then have that code try to allocate memory on the same node as the
> > appropriate CPU.
> 
> We can do that ... but i hope that MCA error recovery isn't a common
> enough path that allocating min_state from the correct node ever shows
> up on anyone's performance radar!
 
True, but on NUMA systems (at least ours) you want MINSTATE area to be node
local for other reasons. Some types of errors cause the interconnect to fail.
The PAL/SAL should be able to log errors without making offnode references.




-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

