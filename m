From: Horms <horms@verge.net.au>
Date: Thu, 08 Feb 2007 13:07:37 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <20070208130736.GC7304@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 08, 2007 at 03:52:15PM +0800, Zou, Nanhai wrote:
> 
>   Those values are wrong, 
> Could you test we a 2.6.20 plus the patch? 

I tried 2.6.20 + your patch.
I tried the same with the addition of Bob Picco's patch to stop
the crash-kernel crashing.
And I tried with Sparse and Discontig memory.
And in all cases I get much the same result :(

I'm wondering if perhaps its got something to do with kexec-tools,
I'm using kexec-tools-testing from git. Is there any possibility
you could send a static binary the version that you are using
(if its from Eric's old tree cross compiling doesn't really work)?

Or perhaps my kernel config is odd.

> Also it will be helpful to print efi_memmap in purgatory code.

Indeed. Do you have any way to dump purgatory's console across
a serial port? The vga console and I are on opposite sides of town
at the moent.


-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

