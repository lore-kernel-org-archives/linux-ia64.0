From: Eric Piel <Eric.Piel@Bull.Net>
Date: Thu, 10 Apr 2003 13:13:15 +0000
Subject: [Linux-ia64] [BUG] perfmon doesn't send SIGPROF in kernel 2.5.64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------12EC844D083639BCB0E77298"
Message-Id: <marc-linux-ia64-105590723705454@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------12EC844D083639BCB0E77298
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello,

Since kernel 2.5.60 the perfmon doesn't send SIGPROF to the designated
task. The problem can be solved by replacing perfmon.c by an older
version (eg: from a kernel 2.5.59). Upgrading to perfmon 1.4 doesn't
solve this bug.
My testcase is the program "realfeel4" from peter Chubb available on the
perfmon website (and attached to this e-mail). 

On a kernel 2.5.6{0,4} : 
# ./realfeel4
897.533 MHz
secondsPerTick=1.11417e-09
ticksPerSecond=897532585.408894
sample_period = 6282728
smallest = 18446744073709551615, largest = 0, nsamples = 0, sigma = 0,
sigmasqr = 0

While we should expect something like on a kernel 2.5.59:
# ./realfeel4 
897.527 MHz
secondsPerTick=1.11417e-09
ticksPerSecond=897526816.648964
sample_period = 6282687
smallest = 4859, largest = 8216, nsamples = 1426, sigma = 7948200,
sigmasqr = 44510579922
Mean 5573.77, stddev 382.946


nsamples = 0 means it didn't receive any signal: that's bad :-)

It seems the reason of the bug is the new, indirect, way to deliver the
signals. Now perfmon relies on do_notify_resume_user() to call
pfm_ovfl_block_reset(). I think the bugs stands somewhere there because
do_notify_resume_user() isn't called so often (when I tested it, only
once the timer of realfeel4 was over). Unfortunatly I didn't understand
all the mechanism of the signals and in addition ia64_leave_kernel() is
coded in assembly, that doesn't help ;-).

I would be very greetful if someone could have a look at it or, at
least, could give me some clues about how the kernel decides when to
call do_notify_resume_user().

Eric
--------------12EC844D083639BCB0E77298
Content-Type: text/plain; charset=us-ascii;
 name="realfeel4.c"
Content-Disposition: inline;
 filename="realfeel4.c"
Content-Transfer-Encoding: 7bit

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
#include <perfmon/pfmlib.h>

typedef unsigned long stamp_t;

static inline stamp_t time_stamp(void)
{
  stamp_t result;
  __asm__ __volatile__("mov %0=ar.itc;;" : "=r"(result) :: "memory");
  return result;
}

static pid_t me;
long sample_period;


#define NUM_PMDS PMU_MAX_PMDS

static pfarg_reg_t pd[NUM_PMDS];
static pfmlib_param_t evt;


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

	while (alarmed==0 && sigsuspend(&mask))
	  ;
}

static void
process(stamp_t now)
{
	static stamp_t last;

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
	/*
	 * And resume monitoring
	 */
	if (perfmonctl(me, PFM_RESTART,NULL, 0) == -1) {
		perror("PFM_RESTART");
		exit(1);
	}
}



static void
overflow_handler(int n, struct pfm_siginfo *info, struct sigcontext *sc)
{
	unsigned long mask = info->sy_pfm_ovfl[0];

	stamp_t now = time_stamp();

	/*
	 * Check to see if we received a spurious SIGPROF, i.e., one not
	 * generated by the perfmon subsystem.
	 */
	if (info->sy_code != PROF_OVFL) {
		printf("Received spurious SIGPROF si_code=%d\n", info->sy_code);
		return;
	} 
	/*
	 * Each bit set in the overflow mask represents an overflowed counter.
	 *
	 * Here we check that the overflow was caused by our first counter.
	 */
	if ((mask & (1UL<< evt.pfp_pc[0].reg_num)) == 0) {
		printf("Something is wrong, unexpected mask 0x%lx\n", mask);
		exit(1);
	}
	process(now);
}

int
main(int argc, char **argv)
{
	int  ret;
	pfarg_context_t ctx[1];
	pfmlib_options_t pfmlib_options;
	struct sigaction act;


	me = getpid();

 
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
	sigaction(SIGPROF, &act, 0);

	/*
	 * pass options to library (optional)
	 */
	memset(&pfmlib_options, 0, sizeof(pfmlib_options));
	pfmlib_options.pfm_debug = 0; /* set to 1 for debug */
	pfm_set_options(&pfmlib_options);

	memset(pd, 0, sizeof(pd));
	memset(ctx, 0, sizeof(ctx));

	/*
	 * prepare parameters to library. we don't use any Itanium
	 * specific features here. so the pfp_model is NULL.
	 */
	memset(&evt, 0, sizeof(evt));

	if (pfm_find_event("cpu_cycles", &evt.pfp_events[0].event) != PFMLIB_SUCCESS) {
			fatal_error("Cannot find cpu_cycles event\n");
	}

	/*
	 * set the default privilege mode for all counters:
	 * 	PFM_PLM3 : user level 
	 *	PFM_PLM0 : kernel level
	 */
	evt.pfp_dfl_plm = PFM_PLM0|PFM_PLM3;
	evt.pfp_flags = PFMLIB_PFP_SYSTEMWIDE;
	/*
	 * how many counters we use
	 */
	evt.pfp_event_count = 1;

	/*
	 * use the library to find the monitors to use
	 */
	if ((ret = pfm_dispatch_events(&evt)) != PFMLIB_SUCCESS) {
		fatal_error("Cannot configure events: %s\n", pfm_strerror(ret));
	}
	/*
	 * For this example, we want to be notified on counter overflows.
	 */
	ctx[0].ctx_flags      = PFM_FL_SYSTEM_WIDE;
	ctx[0].ctx_notify_pid = me;
	ctx[0].ctx_cpu_mask = 1;
	/*
	 * now create the context for self monitoring/across system
	 */
	if (perfmonctl(me, PFM_CREATE_CONTEXT, ctx, 1) == -1 ) {
		if (errno == ENOSYS) {
			fatal_error("Your kernel does not have performance monitoring support!\n");
		}
		fatal_error("Can't create PFM context %s\n", strerror(errno));
	}
	/* 
	 * Must be done before any PMD/PMD calls (unfreeze PMU). Initialize
	 * PMC/PMD to safe values. psr.up is cleared.
	 */
	if (perfmonctl(me, PFM_ENABLE, NULL, 0) == -1) {
		fatal_error( "child: perfmonctl error PFM_ENABLE errno %d\n",errno);
	}

	/*
	 * We want to get notified when the counter used for our first
	 * event overflows
	 */
	evt.pfp_pc[0].reg_flags 	|= PFM_REGFL_OVFL_NOTIFY;

	pd[0].reg_num = evt.pfp_pc[0].reg_num;



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
	if (perfmonctl(me, PFM_WRITE_PMCS, evt.pfp_pc, evt.pfp_pc_count) == -1) {
		fatal_error("child: perfmonctl error PFM_WRITE_PMCS errno %d: %s\n",errno, strerror(errno));
	}

	if (perfmonctl(me, PFM_WRITE_PMDS, pd, evt.pfp_event_count) == -1) {
		fatal_error( "child: perfmonctl error PFM_WRITE_PMDS errno %d: %s\n",errno, strerror(errno));
	}

	/*
	 * Let's roll now
	 */
	perfmonctl(me, PFM_START, 0, 0);

	delay(10);

	perfmonctl(me, PFM_STOP, 0, 0);

	/* 
	 * let's stop this now
	 */
	if (perfmonctl(me, PFM_DESTROY_CONTEXT, NULL, 0) == -1) {
		fatal_error( "child: perfmonctl error PFM_DESTROY errno %d\n",errno);
	}

	printf("smallest = %lu, largest = %lu, nsamples = %lu, sigma = %lu, sigmasqr = %lu\n",
	       smallest, largest, nsamples, sigma, sigmasqr);
	if (nsamples) {
		printf("Mean %g, stddev %g\n",
		       (double)sigma/(double)nsamples,
		       sqrt(((double)sigmasqr - (double)(sigma * sigma)/(double)nsamples)/(double)nsamples));
	}
	return 0;
}

--------------12EC844D083639BCB0E77298--


