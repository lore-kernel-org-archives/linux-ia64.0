From: "H. J. Lu" <hjl@lucon.org>
Date: Mon, 08 Mar 2004 23:59:15 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap and munmap
Message-Id: <20040308235915.GA2785@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 09, 2004 at 10:43:45AM +1100, Shaun wrote:
> 
> Hi,
> 
> I'm not sure if this is a known issue or not, but we have been having some
> trouble running some of our programs under the IA32 emulation layer of
> linux-ia64.
> 
> What is happening in our case is that our program is indirectly causing
> lots of mmaps of anonymous memory for 4096 bytes. Shortly thereafter these
> blocks are munmaped. The munmap is effectively ignored causing the program
> to leak a page (16K in our kernel) of virtual memory.
> 
> The situation can be illustrated with the following code when compiled on
> an IA32 system then run on a IA64 system:
> 
> for (int i = 0; i < 10000; i++)
> {
>    pvAddr = mmap(NULL, getpagesize(), PROT_READ|PROT_WRITE,
>                  MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
>    printf("%p\n", pvAddr);
>    munmap(pvAddr, getpagesize());
> }
> 
> Given that getpagesize() is hardcoded in glibc it returns 4096, the mmap

getpagesize () isn't hardcoded to 4K in glibc. You can change it with
AT_PAGESZ. The problem is the x86 executable is aligned at 4K page
size, which is specified by the i386 ABI. The dynamic linker in glibc
won't load the normal x86 executables with a bigger page size. I have
a glibc patch which allows >4K page size. It may work for you.


H.J.
