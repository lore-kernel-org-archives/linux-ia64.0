From: Jesse Barnes <jbarnes@sgi.com>
Date: Fri, 09 May 2003 17:52:25 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 07, 2003 at 04:24:09PM -0700, Luck, Tony wrote:
> 1) My patch (posted around October last year) which picked virtual addresses
> in the wild blue yonder (initial versions used 0xe002000000000000, later ones
> used 0xffffffff00000000) for the link address for the kernel. Elilo can load
> kernel at any suitably aligned physical address, and head.S establishes the
> mappings using itr[0] and dtr[0].
> 
>  pros) provided separate maps for kernel text and data, so supported kernel text
>        replication too.
>  cons) __pa() no longer works on kernel addresses, use new __tpa() instead.
>        Some ugly runtime patching of kernel code to get physical address of
>        swapper_pg_dir into the TLB miss code.
> 
> 2) I think SGI are currently running a modified version of #1 without the text
> replication support, and that provides a mapping from the normal virtual
> address that the kernel is linked for (0xe00000000044000000) to whatever physical
> address it was actually loaded at ... at least I think that's what Jack said.
> 
>  pros) simpler than my patch
> 
>  cons) Still needs __tpa() instead of __pa() for kernel addresses.
> 
> 3) David's suggestion of boot-time relocation.  Probably simplest to implement
> this in elilo, but if you are really good at PIC asm code it could be done in
> the kernel startup sequence.
> 
>  pros) Just like linking kernel at a new address.
>        Avoids the __tpa() issue.
>        Doesn't invalidate any assumptions about how to get from virtual to
>        physical addresses and back again.
> 
>  cons) Nobody has implemented it.
         doesn't address text replication concerns, while (1) and (2)
         do

So, is there any consensus on the best path to pursue?  Chris Wedgwood
is working on option #3, and I've got Tony's patch trimmed down to #2
(with one piece missing--ia64_switch_to runtime patching), but none of
these are in either 2.4 or 2.5 yet.  Maybe for 2.4 we should do #2 or
#3 and for 2.5 we could implement #1 with the virtual offsets Tony
mentioned earlier?

Thanks,
Jesse

