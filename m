From: "Martin K. Petersen" <mkp@sgi.com>
Date: Wed, 13 Oct 2004 20:34:30 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <yq1acuqtl0p.fsf@wilson.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Robin" = Robin Holt <holt@sgi.com> writes:

Robin> Martin, can you send your updated test case.  I believe yours
Robin> is just mine with a higher resolution timer. 

Sure.  Included below.

-- 
Martin K. Petersen	Silicon Graphics, Inc.
mkp@sgi.com		http://www.sgi.com/

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <time.h>
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
	pid_t child;
	int child_status;
	int fd;
	long long start, end;
	struct timespec ts;

	mapping = mmap(NULL, (size_t) MAPPING_SIZE, PROT_READ,
		       MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

	if ((unsigned long) mapping = -1UL) {
		perror("Mapping failed.\n");
		exit(0);
	}

	for (j=0; j < LOOPS_TO_TIME; j++) {
		child = fork();
		if (child > 0) {
			wait(&child_status);
		} else if (child = 0) {
			clock_gettime(CLOCK_REALTIME, &ts);
			start = ts.tv_sec * 1000000000 + ts.tv_nsec;

			for (i = 0; i < FAULTS_TO_CAUSE; i++) {
				offset = i * STRIDE;
				z = mapping[offset];
			}

			clock_gettime(CLOCK_REALTIME, &ts);
			end = ts.tv_sec * 1000000000 + ts.tv_nsec;

			printf("Took %lld nanoseconds per fault\n",
			       (end-start) / FAULTS_TO_CAUSE);
			exit(0);
		} else {
			printf ("Fork failed\n");
		}
	}
	munmap(mapping, (size_t) MAPPING_SIZE);
	return 0;
}
