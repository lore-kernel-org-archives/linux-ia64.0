From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Feb 2003 23:26:10 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.60)
Message-Id: <marc-linux-ia64-105590709805837@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch is now at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/linux-2.5.60-ia64-030212.diff.gz

This is mostly a sync with Linus' tree.  The patch above contains some
non-ia64 patches which are there because Linus pushed them into his
bitkeeper tree after releasing 2.5.60 and before I picked it up.

do_gettimeofday() is now lock-free and this required some
modifications to the logic that ensures that non-one can observe time
going backwards.  Actually, since multiple do_gettimeofday() calls now
can execute truly in parallel, the very notion of "time not going
backwards" becomes more interesting.  So the refined requirement is
that no causally dependent do_gettimeofday() calls will ever observe
time going backwards.  The logic that I'm now using guarantees that
(in the absence of bugs ;-), but there is a tiny possibility that time
sometimes will jump forward a little (again, this is rather unlikely
and the amount of the forward jump is normally bounded by the timer
tick period, which is about 1ms on ia64).  Based on my testing, it all
works as expected and the observed behavior is virtually
indistinguishable between 2.5.59 and 2.5.60 (apart from the 2.5.60
gettimeofday() being much more scalable and slightly faster).  But I'd
definitely appreciate it if interested folks looked over the code and
could try to find holes in it.

For the record, I attached some measurements.  Thought they might come
in handy if/when someone develops a lightweight version of
gettimeofday (Peter? ;-)).  In the tables below, "lat" is the average
latency of a gettimeofday() system call, "max" is the maximum elapsed
time between a pair of gettimeofday() calls in a sequence of 10
million calls.  Of course, the latter number can be quite large, if
the task got rescheduled or if something disabled interrupts for a
long time.  But still, tracking this difference on a reasonably idle
system can give some interesting insights into how things work.  Each
table contains 10 runs of the test program and all numbers are in
micro-seconds.

Enjoy,

	--david

v2.5.60:

  1-way McKinley		  2-way McKinley
lat		max		lat		max
0.568107	100		0.574615	101
0.569987	307		0.574272	101
0.567009	100		0.573913	101
0.56967 	100		0.574309	236
0.564719	100		0.575047	102
0.563109	100		0.576051	102
0.569994	213		0.574715	101
0.567091	100		0.575147	101
0.563048	100		0.575479	101
0.569834	100		0.576054	102


v2.5.59:

  1-way McKinley		   2-way McKinley
0.589787	177		0.577409	100
0.590431	100		0.57823 	100
0.591788	358		0.579722	101
0.590739	100		0.577402	101
0.590888	189		0.579319	100
0.590353	100		0.578492	100
0.590847	100		0.576145	101
0.590158	100		0.573804	101
0.589569	212		0.579002	100
0.590141	100		0.580514	100

