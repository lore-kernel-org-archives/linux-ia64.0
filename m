From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 30 Mar 2004 18:42:28 +0000
Subject: Re: realfeel4 for libpfm-3.0
Message-Id: <20040330184228.GD27493@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F842DB199@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F842DB199@PDSMSX403.ccr.corp.intel.com>
To: linux-ia64@vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Tue, Mar 30, 2004 at 02:07:59PM +0800, Zhu, Yi wrote:
> 
> I'm a user of realfeel4.
> 
> Recently SuSE ships SLES 9 beta with 2.6 kernel and libpfm-3.0.
> Since libpfm 3.0 changes its interface from 2.0, I cannot compile
> realfeel4.c. Do you have a version of realfeel4 that works on
> libpfm-3.0?
> 
I looked at your ported version of realfeel4.c. There were three
problems with it:

	- with the new perfmon interface, a system-wide context
	  is not automatically pinned to a CPU. You need an
	  explicit call to sched_setaffinity(). The perfmonctl()
	  calls, in this case, are only authorized from when the
	  calling tasking is running on the CPU that was used when
	  PFM_LOAD_CONTEXT was issued. To avoid problems it is always
	  best to explicitely call sched_setaffinity() prior to 
	  PFM_LOAD_CONTEXT.

	- for system-wide context, you currently cannot use
	  pfm_self_start()/pfm_self_stop() which are lighweight
	  versions of PFM_START/PFM_STOP. I am hoping to remove
	  this restrictions soon.

	- You had two calls to PFM_RESTART in you overflow handler.

The attached program does work for me.


-- 

-Stephane

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="realfeel4n.c"

/*
 * realfeel4.c -- produce histogram of interrupt to user-space latency.
 *
 * Based on notify-self.c from the pfmon2.0 package and realfeel.c from
 *  Mark Hahn http://brain.mkmaster.ca/~hahn/realfeel.c
 *
 * Portions Copyright (C) 2001-2002 Hewlett-Packard Co
 * Contributed by Stephane Eranian <eranian@hpl.hp.com>
 *
 * Released under GPL.
 */

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <math.h>
#include <limits.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sched.h>
#include <string.h>
#include <fcntl.h>
#include <perfmon/pfmlib.h>
#include <perfmon/perfmon.h>
#include <perfmon/perfmon_default_smpl.h>
#include <perfmon/pfmlib_itanium2.h>

typedef unsigned long stamp_t;

static inline stamp_t time_stamp(void)
{
  stamp_t result;
  __asm__ __volatile__("mov %0=ar.itc;;" : "=r"(result) :: "memory");
  return result;
}

long sample_period;


#define NUM_PMDS PFMLIB_MAX_PMDS
#define NUM_PMCS PFMLIB_MAX_PMCS

static pfarg_reg_t pd[NUM_PMDS];
pfarg_reg_t pc[NUM_PMCS];
static pfmlib_input_param_t inp;
static pfmlib_output_param_t outp;
static void *smpl_vaddr;
static unsigned int entry_size;
static int ctx_fd;


static stamp_t smallest = ULONG_MAX;
static stamp_t largest;

static unsigned long nsamples;
static unsigned long sigma;
static unsigned long sigmasqr;


static void fatal_error(char *fmt,...) __attribute__((noreturn));

static void
fatal_error(char *fmt, ...) 
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	exit(1);
}


int set_realtime_priority(void)
{
	struct sched_param schp;
	/*
	 * set the process to realtime privs
	 */
	memset(&schp, 0, sizeof(schp));
	schp.sched_priority = sched_get_priority_max(SCHED_FIFO);
	
	if (sched_setscheduler(0, SCHED_FIFO, &schp) != 0) {
		perror("sched_setscheduler");
		exit(1);
	}

	return 0;
}

double second() {
	struct timeval tv;
	gettimeofday(&tv,0);
	return tv.tv_sec + 1e-6 * tv.tv_usec;
}

typedef unsigned long long u64;

void selectsleep(unsigned us) {
	struct timeval tv;
	tv.tv_sec = 0;
	tv.tv_usec = us;
	select(0,0,0,0,&tv);
}

double secondsPerTick, ticksPerSecond;

void calibrate()
{
	double sumx = 0;
	double sumy = 0;
	double sumxx = 0;
	double sumxy = 0;
	double slope;

	// least squares linear regression of ticks onto real time
	// as returned by gettimeofday.

	const unsigned n = 30;
	unsigned i;

	for (i=0; i<n; i++) {
		double breal,real,ticks;
		stamp_t bticks;
	
		breal = second();
		bticks = time_stamp();

		selectsleep((unsigned)(10000 + drand48() * 200000));

		ticks = time_stamp() - bticks;
		real = second() - breal;

		sumx += real;
		sumxx += real * real;
		sumxy += real * ticks;
		sumy += ticks;
	}
	slope = ((sumxy - (sumx*sumy) / n) /
		 (sumxx - (sumx*sumx) / n));
	ticksPerSecond = slope;
	secondsPerTick = 1.0 / slope;
	printf("%3.3f MHz\n",ticksPerSecond*1e-6);
}





sig_atomic_t alarmed;
static void alrm(int signo)
{
  alarmed = 1;
}

static void delay(unsigned seconds)
{
	sigset_t mask;
	sigemptyset(&mask);

	signal(SIGALRM, alrm);
	signal(SIGINT, alrm);
	alarmed = 0;
	alarm(seconds);

	while (alarmed==0 && sigsuspend(&mask));

	printf("alarmed=%d\n", alarmed);
}

static void
process(stamp_t now)
{
	static stamp_t last;
	unsigned long m;

	if (last) {
		stamp_t diff = now - last;
		if (now < last)
			diff = ~(stamp_t)0 - last + now + 1;
		nsamples++;
		diff -= sample_period;
		sigma += diff;
		sigmasqr += diff * diff;
		if (diff < smallest)
			smallest = diff;
		if (diff > largest)
			largest = diff;
	}
	last = now;
}

void
process_smpl_buffer(void)
{
	pfm_default_smpl_hdr_t *hdr;
	pfm_default_smpl_entry_t *ent;
	unsigned long pos;
	unsigned long smpl_entry = 0;
	pfm_ita2_pmd_reg_t *reg, *pmd16;
	unsigned long i;
	int ret;
	static unsigned long last_ovfl = ~0UL;


	hdr = (pfm_default_smpl_hdr_t *)smpl_vaddr;

	/*
	 * check that we are not diplaying the previous set of samples again.
	 * Required to take care of the last batch of samples.
	 */
	if (hdr->hdr_overflows <= last_ovfl && last_ovfl != ~0UL) {
		printf("skipping identical set of samples %lu <= %lu\n", hdr->hdr_overflows, last_ovfl);
		return;
	}

	pos = (unsigned long)(hdr+1);
	/*
	 * walk through all the entries recored in the buffer
	 */
	for(i=0; i < hdr->hdr_count; i++) {

		ret = 0;

		ent = (pfm_default_smpl_entry_t *)pos;
		/*
		 * print entry header
		 */
		printf("Entry %ld PID:%d CPU:%d STAMP:0x%lx IIP:0x%016lx\n",
			smpl_entry++,
			ent->pid,
			ent->cpu,
			ent->tstamp,
			ent->ip);

		/*
		 * point to first recorded register (always contiguous with entry header)
		 */
		reg = (pfm_ita2_pmd_reg_t*)(ent+1);

		/*
		 * in this particular example, we have pmd8-pmd15 has the BTB. We have also
		 * included pmd16 (BTB index) has part of the registers to record. This trick
		 * allows us to get the index to decode the sequential order of the BTB.
		 *
		 * Recorded registers are always recorded in increasing order. So we know
		 * that pmd16 is at a fixed offset (+8*sizeof(unsigned long)) from pmd8.
		 */
		pmd16 = reg+8;
		//show_btb(reg, pmd16);

		/*
		 * move to next entry
		 */
		pos += entry_size;
	}
}

static void
overflow_handler(int n, struct siginfo *info, struct sigcontext *sc)
{
	stamp_t now = time_stamp();

	/* dangerous */
	//printf("Notification received\n");

	//process_smpl_buffer();
	process(now);

	/*
	 * And resume monitoring
	 */
	if (perfmonctl(ctx_fd, PFM_RESTART,NULL, 0) == -1) {
		perror("PFM_RESTART");
		exit(1);
	}
}

#ifndef SYS_sched_setaffinity
# define SYS_sched_setaffinity 1231

int
sched_setaffinity (pid_t pid, unsigned int len, unsigned long *mask)
{
  return syscall (SYS_sched_setaffinity, pid, len, mask);
}

#endif


int
main(int argc, char **argv)
{
	int ret;
	int i;
	pfarg_context_t ctx[1];
	pfmlib_options_t pfmlib_options;
	struct sigaction act;
	pfarg_load_t load_args;
	unsigned long cpu_mask;

	if (mlockall(MCL_CURRENT|MCL_FUTURE) != 0) {
		perror("mlockall");
		exit(1);
	}

	set_realtime_priority();
	calibrate();

	printf("secondsPerTick=%g\n", secondsPerTick);
	printf("ticksPerSecond=%f\n", ticksPerSecond);

	/*
	 * Initialize pfm library (required before we can use it)
	 */
	if (pfm_initialize() != PFMLIB_SUCCESS) {
		printf("Can't initialize library\n");
		exit(1);
	}

	/*
	 * Install the overflow handler (SIGPROF)
	 */
	memset(&act, 0, sizeof(act));
	act.sa_handler = (sig_t)overflow_handler;
	act.sa_flags = SA_NOMASK;
	sigaction(SIGIO, &act, 0);

	/*
	 * pass options to library (optional)
	 */
	memset(&pfmlib_options, 0, sizeof(pfmlib_options));
	pfmlib_options.pfm_debug = 0; /* set to 1 for debug */
	pfm_set_options(&pfmlib_options);

	memset(pd, 0, sizeof(pd));
	memset(ctx, 0, sizeof(ctx));
        memset(&load_args, 0, sizeof(load_args));

	/*
	 * prepare parameters to library. we don't use any Itanium
	 * specific features here. so the pfp_model is NULL.
	 */
	memset(&inp, 0, sizeof(inp));
        memset(&outp,0, sizeof(outp));

	if (pfm_find_event("cpu_cycles", &inp.pfp_events[0].event) != PFMLIB_SUCCESS) {
			fatal_error("Cannot find cpu_cycles event\n");
	}

	/*
	 * set the default privilege mode for all counters:
	 * 	PFM_PLM3 : user level 
	 *	PFM_PLM0 : kernel level
	 */
	inp.pfp_dfl_plm = PFM_PLM0|PFM_PLM3;
	inp.pfp_flags = PFMLIB_PFP_SYSTEMWIDE;
	/*
	 * how many counters we use
	 */
	inp.pfp_event_count = 1;

	/*
	 * use the library to find the monitors to use
	 */
	if ((ret = pfm_dispatch_events(&inp, NULL, &outp, NULL)) != PFMLIB_SUCCESS) {
		fatal_error("Cannot configure events: %s\n", pfm_strerror(ret));
	}
	/*
	 * set affinity to CPU0
	 */
	cpu_mask = 1UL;
	ret = sched_setaffinity(getpid(), sizeof(unsigned long), &cpu_mask);
	if (ret == -1) fatal_error("cannot set affinity: %d\n", errno);

	/*
	 * For this example, we want to be notified on counter overflows.
	 */
	ctx[0].ctx_flags      = PFM_FL_SYSTEM_WIDE | PFM_FL_OVFL_NO_MSG;
	/*
	 * now create the context for self monitoring/across system
	 */
	if (perfmonctl(0, PFM_CREATE_CONTEXT, ctx, 1) == -1 ) {
		if (errno == ENOSYS) {
			fatal_error("Your kernel does not have performance monitoring support!\n");
		}
		fatal_error("Can't create PFM context %s\n", strerror(errno));
	}
	ctx_fd = ctx->ctx_fd;
	/*
	 * We want to get notified when the counter used for our first
	 * event overflows
	 */
	pc[0].reg_flags 	|= PFM_REGFL_OVFL_NOTIFY;
	pc[0].reg_reset_pmds[0] |= 1UL << outp.pfp_pmcs[1].reg_num;

	pc[0].reg_num   = outp.pfp_pmcs[0].reg_num;
	pc[0].reg_value = outp.pfp_pmcs[0].reg_value;

	pd[0].reg_num	= outp.pfp_pmcs[0].reg_num;


	/*
	 * we arm the first counter, such that it will overflow
	 * after sample_period events have been observed -- around 7ms
	 */
	sample_period = 7 * ticksPerSecond / 1000; 
	printf("sample_period = %lu\n", sample_period);
	pd[0].reg_value       = (~0UL) - sample_period;
	pd[0].reg_short_reset  = (~0UL) - sample_period;
	pd[0].reg_long_reset  = (~0UL) - sample_period;

	/*
	 * Now program the registers
	 *
	 * We don't use the save variable to indicate the number of elements passed to
	 * the kernel because, as we said earlier, pc may contain more elements than
	 * the number of events we specified, i.e., contains more than counting monitors.
	 */
	if (perfmonctl(ctx_fd, PFM_WRITE_PMCS, pc, outp.pfp_pmc_count) == -1) {
		fatal_error("child: perfmonctl error PFM_WRITE_PMCS errno %d: %s\n",errno, strerror(errno));
	}

	if (perfmonctl(ctx_fd, PFM_WRITE_PMDS, pd, inp.pfp_event_count) == -1) {
		fatal_error( "child: perfmonctl error PFM_WRITE_PMDS errno %d: %s\n",errno, strerror(errno));
	}

	/*
         * we want to monitor ourself
         */
        load_args.load_pid = getpid();

	if (perfmonctl(ctx_fd, PFM_LOAD_CONTEXT, &load_args, 1) == -1) {
                fatal_error("perfmonctl error PFM_WRITE_PMDS errno %d\n",errno);
        }

	/*
         * setup asynchronous notification on the file descriptor
         */
        ret = fcntl(ctx_fd, F_SETFL, fcntl(ctx_fd, F_GETFL, 0) | O_ASYNC);
        if (ret == -1) {
                fatal_error("cannot set ASYNC: %s\n", strerror(errno));
        }


        /*
         * get ownership of the descriptor
         */
        ret = fcntl(ctx_fd, F_SETOWN, getpid());
        if (ret == -1) {
                fatal_error("cannot setown: %s\n", strerror(errno));
        }

	/*
	 * Let's roll now
	 */
	perfmonctl(ctx_fd, PFM_START, 0, 0);

	delay(10);

	perfmonctl(ctx_fd, PFM_STOP, 0, 0);


	/* 
	 * let's stop this now
	 */

	printf("smallest = %lu, largest = %lu, nsamples = %lu, sigma = %lu, sigmasqr = %lu\n",
	       smallest, largest, nsamples, sigma, sigmasqr);
	if (nsamples) {
		printf("Mean %g, stddev %g\n",
		       (double)sigma/(double)nsamples,
		       sqrt(((double)sigmasqr - (double)(sigma * sigma)/(double)nsamples)/(double)nsamples));
	}

	close(ctx_fd);
	return 0;
}

--SUOF0GtieIMvvwua--
