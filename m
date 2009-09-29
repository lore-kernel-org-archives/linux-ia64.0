From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 29 Sep 2009 00:03:36 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <4AC14ED8.4030407@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Here are the source and disassembled binary for the lock/unlock
> routines modified as suggested by Linus to fit the lock word
> back into 32-bits.
> 
> Performance for lock/unlock time in the uncontended in-cache case
> is a little worse (another 8% on top of the 8% I'd already given
> up compared to the original "xchg" version). 

Youch, that is 17% if I've done the math correctly.  This is to deal with 
contended locks more "fairly" correct?

> I haven't tried a macro-level benchmark yet to see whether this makes it
> noticeable.

Not exactly macro with a big M, but something like netperf aggregate TCP_RR 
would probably do a fair bit of lock/unlock exercise.

Taking ftp://ftp.netperf.org/netperf/netperf-2.4.5.tar.bz2

then

tar xjf netperf-2.4.5-tar.bz2
cd netperf-2.4.5
./configure --enable-burst --prefix=<your choice>
make install
netserver

and then it should be possible to see what the max single-connection, 
single-byte, aggregate TCP_RR perf is with something like:

for b in 0 1 4 16 64 256
do
netperf -t TCP_RR -i 30,3 -P 0 -B "burst $b" -- -r 1 -D -b $b
done

where the values for b can be as you choose - 0 means no additional transaction 
in flight at one time, so just the one synchronous transaction.  The -i 30,3 
means repeat each data point at least 3 times but no more than 30 to get the 
default confidence interval of 99% confident the result is within +/- 2.5% (you 
can make that stricter with -I 99,N where N is 2x the +/- you want).  The -P 0 
tells netperf to omit the test banner (makes the output more readable).  The -B 
is a user supplied tag emitted with the result.  The options after the "--" are 
test-specific - in this case -r 1 means request and response size of 1 byte, -D 
means set TCP_NODELAY and the -b $b means add an additional $b transactions in 
flight at one time on the connection.

You may need/want to mess with a global (before the "--") -T option to bind 
netperf/netserver to specific cores:

-T N   # both netperf and netserver to core N on their respective systems
-T N,  # just netperf to core N, netserver floats
-T  ,M # netperf floats, netserver to core M
-T N,M # netperf to N, netserver to M

Once you have come-up with the peak setting for the -b option, you can then do a 
variation on the theme to run multiple, concurrent netperfs:

for i in 1 2 ...
do
netperf -t TCP_RR -i 30 -P 0 -- -r 1 -D -b <burst> &
done

where now each backgrounded netperf will run 30 iterations no matter what - you 
may still want to mess about with the scripting and bind netperf/netserver as 
you wish, or not.  I find the binding helps make things more repeatable.

rick jones
