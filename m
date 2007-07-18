From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 14:58:55 +0000
Subject: [PATCH 0/3] fix ia64 clocksource
Message-Id: <469E2AAF.30705@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

This is a set of patch for ia64 clocksource to improve performance
of fsys_gettimeofday (and also normal gettimeofday).

 [1/3] copy time structures into fsys_gtod_data
 [2/3] separate data for jitter compensation
 [3/3] remove cmpxchg loop in gettimeofday

Finally, the results of my test at start:

> # clocksource (Bob's) : default
> CPU  0:  4.66 (usecs) (0 errors / 2145680 iterations)
> CPU  1:  4.65 (usecs) (493 errors / 2148438 iterations)
> CPU  2:  4.63 (usecs) (668 errors / 2159461 iterations)
> CPU  3:  4.62 (usecs) (654 errors / 2163997 iterations)
> # clocksource (Bob's) : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 70945550 iterations)
> CPU  1:  0.14 (usecs) (470 errors / 71640889 iterations)
> CPU  2:  0.14 (usecs) (664 errors / 70960917 iterations)
> CPU  3:  0.14 (usecs) (571 errors / 70956121 iterations)
> # clocksource (Bob's) : nolwsys
> CPU  0:  2.88 (usecs) (0 errors / 3475147 iterations)
> CPU  1:  2.88 (usecs) (0 errors / 3474881 iterations)
> CPU  2:  2.96 (usecs) (0 errors / 3382229 iterations)
> CPU  3:  2.97 (usecs) (0 errors / 3371004 iterations)

are now refined to:

> # clocksource (fixed) : default
> CPU  0:  1.33 (usecs) (0 errors / 7507837 iterations)
> CPU  1:  1.31 (usecs) (0 errors / 7621659 iterations)
> CPU  2:  1.27 (usecs) (0 errors / 7865412 iterations)
> CPU  3:  1.27 (usecs) (0 errors / 7863362 iterations)
> # clocksource (fixed) : nojitter
> CPU  0:  0.14 (usecs) (0 errors / 69608888 iterations)
> CPU  1:  0.14 (usecs) (0 errors / 70277433 iterations)
> CPU  2:  0.14 (usecs) (0 errors / 69632925 iterations)
> CPU  3:  0.14 (usecs) (0 errors / 69606531 iterations)
> # clocksource (fixed) : nolwsys
> CPU  0:  1.48 (usecs) (0 errors / 6770870 iterations)
> CPU  1:  1.48 (usecs) (0 errors / 6777897 iterations)
> CPU  2:  1.49 (usecs) (0 errors / 6728101 iterations)
> CPU  3:  1.49 (usecs) (0 errors / 6703961 iterations)

Thanks,
H.Seto
