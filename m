From: Robin Holt <holt@sgi.com>
Date: Wed, 04 Aug 2004 21:27:32 +0000
Subject: What are the chances I can re-introduce quicklists for PTEs?
Message-Id: <20040804212732.GA17362@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have a micro-benchmark that shows a 9x slowdown from the 2.4 kernel to
the 2.6 kernel.  This appears to be because of a change for x86 resulting
in the removal of PTE quicklists.  I will attach the benchmark.

I am wondering what the chances are of reintroducing some sort of
quicklist for the PTEs?

I see three issues with respect to quicklists:

1)  There are no quicklists for PTEs.
2)  Quicklist addition is not NUMA aware and can result in trapping one
    nodes memory on another node.  With a fork migrate test, approx 40
    pages are allocated from the source nodes memory.  After the thread
    has migrated, the PGD and PMD entries are added to the quicklist of
    the destination node.
3)  The high and low water marks are calculated based on all the memory
    of the system while quicklists are maintained on a percpu basis.

I can not see any particular reason that there are two (or if
I reintroduce PTE quicklists three) seperate quicklists.  They each
contain pages that are pre-zeroed.  What about collapsing them into one.

One suggestion I got from Jack Steiner was to modify the free pages
code so it is aware of pages that have already been zeroed.  This would
eliminate the need for quicklists and could also improve faulting of
anonymous pages when there are page is going to be immediately zeroed.
I don't think I would attempt to tackle this until after quicklists had
been reintroduced.

Thanks,
Robin Holt


#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


#define	PAGE_SIZE		getpagesize()
#define PTES_PER_PMD		(PAGE_SIZE / 8)
#define STRIDE			PTES_PER_PMD * PAGE_SIZE
#define	FAULTS_TO_CAUSE		32
#define MAPPING_SIZE		FAULTS_TO_CAUSE * STRIDE

#define LOOPS_TO_TIME		128


int main(int argc, char **argv)
{
	long offset, i, j;
	char * mapping;
	volatile char z;
	struct timeval tv;
	unsigned long start_ts, end_ts;
	unsigned long total_uSec;
	struct timezone tz;
	pid_t child;
	int child_status;

	tz.tz_minuteswest = 0;

	total_uSec = 0;

	mapping = mmap(NULL, (size_t) MAPPING_SIZE, PROT_READ,
		       MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

	if ((unsigned long) mapping = -1UL) {
		perror("Mapping failed.");
		exit(0);
	}

	for (j=0; j < LOOPS_TO_TIME; j++) {
		child = fork();
		if (child > 0) {
			wait(&child_status);
		} else if (child = 0) {
			gettimeofday(&tv, &tz);
			start_ts = tv.tv_sec * 1000000 + tv.tv_usec;

			for (i = 0; i < FAULTS_TO_CAUSE; i++) {
				offset = i * STRIDE;
				z = mapping[offset];
			}

			gettimeofday(&tv, &tz);
			end_ts = tv.tv_sec * 1000000 + tv.tv_usec;
			total_uSec += (end_ts - start_ts);
			printf("Took %ld uSeconds per fault\n",
			       total_uSec / FAULTS_TO_CAUSE);
			exit(0);
		} else {
			printf ("Fork failed\n");
		}
	}
	munmap(mapping, (size_t) MAPPING_SIZE);
	return 0;
}
