From: Christopher Wedgwood <cw@sgi.com>
Date: Wed, 30 Jul 2003 00:00:26 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952331923555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 03:47:34PM -0700, Luck, Tony wrote:

> min_state areas for MCA will be smaller than a page ... so *my* use
> of this allocator doesn't require multi-page.

I'm guessing you'll only need 1k or 4k per-cpu right?  What about any
padding here?

On Tue, Jul 29, 2003 at 03:54:27PM -0700, David Mosberger wrote:

> Let's stick with a tried-and-true malloc/free-like interface (nobody
> every gets size arguments to free() right, do they?).

I'd like to claim this is too complex and that page would suffice
except clearly for MINSTATE purposes page granularity is wasteful.
Jack also pointed out for MINSTATE handling on SN2 we would want
local-node pages so perhaps something like:

    u64 ia64_uc_alloc(u64 nbytes, int nodeid, int flags);
    void ia64_uc)free(u64 paddr);

Simply claim '0' is not a useful physical address in this sense and
thus signifies and error?

The 'flags' seems overly complex but would be a mechanism to insist
that memory is allocated from the given node (as opposed to just a
hint for locality).

Comments?



  --cw
