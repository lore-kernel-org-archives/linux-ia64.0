From: Arjan van de Ven <arjan@linux.intel.com>
Date: Sat, 05 Jul 2008 22:57:37 +0000
Subject: Re: the printk problem
Message-Id: <486FFC61.5080405@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080625131101.GA6205@digi.com> <20080704104634.GA31634@digi.com>
	<20080704111540.ddffd241.akpm@linux-foundation.org>
	<alpine.LFD.1.10.0807041147450.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807041250220.2815@woody.linux-foundation.org>
	<1215212420.8970.8.camel@pasglop>
	<alpine.LFD.1.10.0807041622270.2815@woody.linux-foundation.org>
	<alpine.LFD.1.10.0807051523180.2847@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.10.0807051523180.2847@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, Peter Anvin <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, parisc-linux@parisc-linux.org

Linus Torvalds wrote:
> 
> On Fri, 4 Jul 2008, Linus Torvalds wrote:
>> Still all happily untested, of course. And still with no actual users 
>> converted.
> 
> Ok, it's tested, and here's an example usage conversion.
> 
> The diffstat pretty much says it all. It _does_ change the format of the 
> stack trace entry a bit, but I don't think it's for the worse (unless it 
> breaks things like the oops tracker - Arjan?)
> 
> It changes the symbol-in-module format from
> 
> 	:ext3:add_dirent_to_buf+0x6c/0x26c
> 
> to
> 
> 	add_dirent_to_buf+0x6c/0x26c [ext3]
> 
> but quite frankly, the latter was the standard format anyway (it's what 
> "sprint_symbol()" gives you), and traps_64.c was the odd man out.
> 

This won't break anything for me actually; I already deal with either case.

$ cat oopsparse.pl | wc -l
1252

the kernel is so inconsistent with oops formats (over time/across architectures)
that once you deal with what there is today... you pretty much deal with everything.

I also like the improvement; I wished something like this existed several times already
in the last few months so for sure

Acked-by: Arjan van de Ven <arjan@linux.intel.com>
