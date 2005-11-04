From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 04 Nov 2005 22:50:26 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <200511042250.jA4MoQg15713@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote on Tuesday, November 01, 2005 7:41 AM
> On 11/1/05, Robin Holt <holt@sgi.com> wrote:
> > I am trying to get time on one of our larger machines today to run the
> > RandomAccess benchmark (as well as some help from somebody that has run
> > these before).  Is there a certain number of cpus you would like this
> > run on or is a 64p box adequate?
> 
> Oh, even a single CPU should be fine.  Just use a large working set. 
> IIRC, about 16GB should ensure that not even the page tables fit in
> the cache (depending on your cache-size, of course).


Robin, here, something as silly as this test program [*] will show you
the performance regression with 4-level page table:

#include <sys/mman.h>

#define SIZE	(16*1024*1024*1024UL)

int main()
{
	char* addr;
	unsigned long i, j, sum;
	unsigned long start, end;

	addr = mmap(0, SIZE, PROT_READ | PROT_WRITE,
		    MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

	/* fault in all the pages */
	for (i=0; i<SIZE; i+384)
		addr[i] = 0;

	asm volatile ("mov %0=ar.itc" : "=r"(start));

	for (j=0; j<100000; j++)
		for (i=0; i<SIZE; i+= (1UL << 25))
			sum += addr[i];

	asm volatile ("mov %0=ar.itc" : "=r"(end));

	printf("time is %ld\n", end - start);
}

With 3-level page table kernel: time is 16405345406
With 4-level page table kernel: time is 26768668506

- Ken


[*] disclaimer: this code can not be even called as a benchmark
    since it does not meet basic benchmark criteria and definitions.
    I did it with maybe 2 minutes or so.  However, given its
    simplicity, such program can be used as an illustrative purpose.

