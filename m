From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 19 May 2003 18:02:41 +0000
Subject: Re: [Linux-ia64] RE: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705948@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Btw, last Friday I tested David's bk tree (plus one additional console
driver patch) on an sn2, and it booted to the point where we got lots
of printks, so your head.S stuff seems fine for us so far.  I'll let
you know if I run into anything more, but I won't be able to test the
kcore stuff until I have it booting and mounting root.

Thanks,
Jesse

On Mon, May 19, 2003 at 10:57:03AM -0700, Luck, Tony wrote:
> Here's what the kcore change looks like if I take the suggestion
> that Andi Kleen made on LKML
>  http://marc.theaimsgroup.com/?l=linux-kernel&m3556903730989&w=2
> to add the kernel to the vmlist.  Combined with the KCORE_BASE
> change (which is 98% included) we avoid the negative addresses
> that required a bunch more changes in Andi's patch.
> 
> I've juggled the addresses around again, moving the kernel up to
> 0xA000004000000000 and VMALLOC_START back down to 0xA000000000030000
> so that the entry for the kernel goes on the *end* of the vmlist,
> so we don't have to uselessly step over it on every call to vmalloc().
> 
> I picked that kernel start address as it is half-way between
> VMALLOC_START and VMALLOC_END for a PAGE_SIZE=4k kernel.  There
> are many alternatives ... choose a different one (between VMALLOC_START
> and VMALLOC_END) if you come up with a good reason for a different
> address.
> 
> This builds and boots on Tiger, and now I can run:
> 
> 	# gdb vmlinux /proc/kcore
> 	(gdb) x/s log_buf
> 
> and see the contents of kernel memory.
> 
> -Tony



