From: Matthew Wilcox <willy@debian.org>
Date: Mon, 05 Aug 2002 21:01:45 +0000
Subject: Re: [Linux-ia64] mmap and malloc questions on IA-64 linux
Message-Id: <marc-linux-ia64-105590701905910@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905877@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905877@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 05, 2002 at 01:31:00PM -0700, David Mosberger wrote:
> That's what the Linux kernel did up to the pre-2.4.0 series of
> patches.  Then Linus ripped the merging logic out and replaced it with
> something simpler.  The old merging logic had some nasty SMP issues,
> IIRC.

Yeah, I think there was a lock inversion ...

> In the standard 2.4.18 kernel, MAX_MAP_COUNT is a hardcoded constant.
> But in either case, AFAIK, the main reason for the existence of the
> limit is to have (some) protection against denial-of-service attacks,
> where a single process would consume huge amounts of kernel memory.
> There is no a-prio limit in the kernel which would prevent you from
> making the number as large as you want (well, within reason: map_count
> is a signed 32-bit variable...).

Well... kind of.  The VMA management algorithms are a RB tree which scales
better than a linked list, but is still not going to perform terribly
well when we get hundreds of thousands of VMAs.  BTW, the find_vma_prev
routine which ia64 uses in its fault handler path could be sped up by
using the one we have in the PA-RISC tree that was merged into 2.5 --
patch was posted to linux-mm:

http://mail.nl.linux.org/linux-mm/2002-06/msg00062.html

-- 
Revolutions do not require corporate support.

