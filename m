From: Christoph Lameter <christoph@lameter.com>
Date: Fri, 04 Jun 2004 15:06:57 +0000
Subject: Re: GLIBC IA64 HP_TIMING fixes for SMP systems with unsynchronized
Message-Id: <Pine.LNX.4.58.0406040804120.16070@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0406031313420.32412@server.home>
In-Reply-To: <Pine.LNX.4.58.0406031313420.32412@server.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 4 Jun 2004, Ulrich Drepper wrote:

> Christoph Lameter wrote:
>
> > clock_gettime(CLOCK_REALTIME) calls gettimeofday internally and then
> > multiplies with 1000.
>
> Internally where?  clock_gettime is a syscall.  And it can use whatever
> functionality the kernel provides.  There is absolutely no requirement
> to add additional clocks, just make clock_gettime do the right think if
> this isn't happening already.

Internally in the kernel. Excerpts from kernel/posix-timers.c:

static int do_posix_gettime(struct k_clock *clock, struct timespec *tp)
{
        struct timeval tv;

        if (clock->clock_get)
                return clock->clock_get(tp);

        do_gettimeofday(&tv);
        tp->tv_sec = tv.tv_sec;
        tp->tv_nsec = tv.tv_usec * NSEC_PER_USEC;

        return 0;
}

static u64 do_posix_clock_monotonic_gettime_parts(
        struct timespec *tp, struct timespec *mo)
{
        u64 jiff;
        struct timeval tpv;
        unsigned int seq;

        do {
                seq = read_seqbegin(&xtime_lock);
                do_gettimeofday(&tpv);
                *mo = wall_to_monotonic;
                jiff = jiffies_64;

        } while(read_seqretry(&xtime_lock, seq));

        /*
         * Love to get this before it is converted to usec.
         * It would save a div AND a mpy.
         */
        tp->tv_sec = tpv.tv_sec;
        tp->tv_nsec = tpv.tv_usec * NSEC_PER_USEC;

        return jiff;
}


