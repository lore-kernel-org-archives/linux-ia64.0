From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 31 Aug 2000 07:12:42 +0000
Subject: Re: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205422@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205422@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 30 Aug 2000 16:54:29 -0700, 
Jim Wilson <wilson@cygnus.com> wrote:
>I am making available new toolchain snapshots, based on July FSF gcc sources.
>These snapshots are available from ftp.cygnus.com in pub/ia64-linux.  The
>current snapshot is in the snap-000828 directory.

I'm getting a lot of warnings for format %p with the new toolchain on
kernel 2.4.0-test7, e.g.

pci-dma.c:100: warning: void format, char arg (arg 2)

static char *io_tlb_start, *io_tlb_end;
        printk("Placing software IO TLB between 0x%p - 0x%p\n", io_tlb_start, io_tlb_end);

What is the correct way to handle these?  Cast all pointers to (void *)
for printing or is there a compiler option I can use to make %p accept
any pointer, i.e. the old behaviour?


