From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 22:37:05 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951854719608@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 03:30:45PM -0700, David Mosberger wrote:

> So the fetchop driver needs regular memory mapped as UC, just like
> the MCA MINSTATE area?

Yes, but it's not used directly as if it were (however that detail is
a matter for the fetchop driver internally).

> If so, a UC memory allocator is certainly the way to go.

It sounds like it.


  --cw
