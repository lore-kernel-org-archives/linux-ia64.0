From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 10 Jul 2007 22:20:09 +0000
Subject: RE: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <617E1C2C70743745A92448908E030B2A01E2D881@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 >>>  	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
 >>> +	;;
 >>>  (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!

The .acq only causes ordering w.r.t. data accesses.  The read from ar.itc
isn't a data access, so potentially it could still float before the
ld4.acq.  Consuming the value loaded into r28 presumably has to
ensure that the load completes though.

I'm guessing here ... I haven't cross-checked with the architects.

Does moving the "and r28 = ~1,r28" up into this slot hurt latency
for a single call to gettimeofday()?  Presumably it will if
xtime_lock.sequence is not in the cache.

-Tony
