From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 21 Apr 2006 14:21:25 +0000
Subject: Re: Protect PGD...PTE walking in ivt.S
Message-Id: <4448EA65.6030607@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4448E85B.5080906@bull.net>
In-Reply-To: <4448E85B.5080906@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The test program:

/*
* This test aims to provoke VHPT misses.
*
* In order to maximize the number of the TLB entries needed for the virtually mapped
* PTE pages, only one valid PTE / page will be used (, and a single byte per data page).
* The TLB pressure will me multiplied by "N" in order not to leave any
* practical chance for a TLB hit.
*
* Remember to allow to over-commit memory: "sysctl -w vm.overcommit_memory=1".
*
* ...there is no control over the physical addresses of the user pages... there will
* be some variation of the results from run to run due to some address aliases...
*
* ...the interrupts are enabled...
*/


#include <sys/types.h>
#include <stdio.h>
#include <sys/mman.h>


#define	N			8	// TLB pressure multiplier
#define	N_RUNS			10
#define	N_EXTERNAL_LOOPS	10
#define	N_INTERNAL_LOOPS	1000

#define	CACHE_BYTES		128
#define	N_TLB_ENTRIES		128

// Not counting the kernel's DTRs...
#define	N_PTE_PAGE_U_PAGE_PAIRS	(N_TLB_ENTRIES / 2 * N)
#define	PTE_PER_CACHE_BYTES	(CACHE_BYTES / sizeof(unsigned long))

unsigned int pagesize;

#define	PTES_PER_PAGE		(pagesize / sizeof(void *))
#define	VA_RANGE_PER_PTE_PAGE	(PTES_PER_PAGE * pagesize)

/*
* Cache line "coloring" in order to reduce cache alias problems.
* (Yet as there is no control over the physical addresses of the user pages...)
* The i-th element touched by the innermost loop will be at the offset in the page:
* (i * 2 + 1) * CACHE_BYTES
* The PTE mapping this test data will be at the offset in its page:
* i * 2 * CACHE_BYTES
*/
#define	OFFSET			(VA_RANGE_PER_PTE_PAGE + \
				2 * PTE_PER_CACHE_BYTES * pagesize + \
				2 * CACHE_BYTES)
unsigned int offset;

#define	TEST_VA_RANGE		((unsigned long) VA_RANGE_PER_PTE_PAGE * \
						N_PTE_PAGE_U_PAGE_PAIRS + \
				/* Cache line "coloring": */ \
				2 * N_PTE_PAGE_U_PAGE_PAIRS * \
						PTE_PER_CACHE_BYTES * pagesize + \
				2 * N_PTE_PAGE_U_PAGE_PAIRS * CACHE_BYTES)

#define	MEM_PROT		(PROT_READ | PROT_WRITE)
#define	MEM_TYPE		(MAP_PRIVATE | MAP_ANONYMOUS)

#define GET_ITC()						\
({								\
	unsigned long ia64_intri_res;				\
								\
	asm volatile ("mov %0=ar.itc" : "=r"(ia64_intri_res));	\
	ia64_intri_res;						\
})


inline unsigned long test(char *p0, unsigned int n)
{
	int		i, j;
	char		*p;
	unsigned long	itc0 = GET_ITC();

	for (j = 0; j < n; j++)
		for (i = 0, p = p0 + CACHE_BYTES;	// Cache line "coloring"
				i < N_PTE_PAGE_U_PAGE_PAIRS; i++, p += offset)
			*p = i;
	return GET_ITC() - itc0;
}


void main_test(void)
{
	void		*p;
	int		loop;
	unsigned long	tmp, sum = 0;

	p = mmap(NULL, TEST_VA_RANGE, MEM_PROT, MEM_TYPE, -1, 0);
	if (p = MAP_FAILED){
		perror("mmap");
		fprintf(stderr, "Have you allowed to over-commit memory? "
				"Try: \"sysctl -w vm.overcommit_memory=1\"\n");
		exit(1);
	}
	(void) test(p, 1);				// Warm up...
	for (loop = 0; loop < N_EXTERNAL_LOOPS; loop++)
		sum += test(p, N_INTERNAL_LOOPS);
	(void) munmap(p, TEST_VA_RANGE);
	printf("ITC ticks: %ld,%03ld,%03ld,",
				sum / 1000000, sum / 1000 % 1000, sum % 1000);
	tmp = (unsigned long) N_EXTERNAL_LOOPS * N_INTERNAL_LOOPS *
							N_PTE_PAGE_U_PAGE_PAIRS;
	printf(" # user accesses: %ld,%03ld,%03ld, ITC ticks / access: %ld\n",
			tmp / 1000000, tmp / 1000 % 1000, tmp % 1000, sum / tmp);
}


int main(int argc, char *argv[])
{
	int		run;
	unsigned long	tmp;

	pagesize = getpagesize();
	offset = OFFSET;			// Depends on "getpagesize()"
	printf("Page size =\t\t\t%12d\n", pagesize);
	printf("PTEs / page =\t\t\t%12d\n", PTES_PER_PAGE);
	printf("VA range / PTE page =\t\t%12d (%d Mbytes)\n",
				VA_RANGE_PER_PTE_PAGE, VA_RANGE_PER_PTE_PAGE >> 20);
	printf("# PTE-page / user-page pairs =\t%12d\n", N_PTE_PAGE_U_PAGE_PAIRS);
	printf("Test VA range =\t\t\t%12ld (%ld Gbytes)\n",
				TEST_VA_RANGE, TEST_VA_RANGE >> 30);
	tmp = N_PTE_PAGE_U_PAGE_PAIRS * pagesize;
	printf("Resident user memory =\t\t%12ld (%ld Mbytes)\n", tmp, tmp >> 20);
	printf("# PTE + user cache lines =\t%12d (%d Kbytes)\n",
				N_PTE_PAGE_U_PAGE_PAIRS * 2,
				N_PTE_PAGE_U_PAGE_PAIRS * 2 * CACHE_BYTES >> 10);
	printf("\n");
	for (run = 0; run < N_RUNS; run++)
		main_test();
	return 0;
}


