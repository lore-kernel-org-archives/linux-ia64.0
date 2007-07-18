From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 18 Jul 2007 09:27:08 +0000
Subject: Re: [PATCH 1/2] ia64 clocksource
Message-Id: <469DDCEC.8040605@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070714002509.GJ2317@localhost>
In-Reply-To: <20070714002509.GJ2317@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

john stultz wrote:
>>> Since gtod_lock.sequence will not tell us whether xtime is updated
>>> (or going to be updated) while in this window, the result may be wrong...
> 
> So w/ x86_64, we've split the xtime_lock and get vgtod_lock, so that
> only when the vsyscall page is being updated do we hold a write on the
> vgtod_lock. This is safe as the vsyscall gtod does not access the
> kernel's time structures (xtime and friends). Instead it reads its copy
> of them that is made in update_vsyscall().
> 
> So it should be fine to use the gtod_lock.sequence, assuming you're also
> not touching the kernel's xtime directly  (and instead using copy of
> xtime made in update_vsyscall).
> 
> Does that make sense?
> -john

Certainly.

Now I have some idea of patch for this ia64 clocksource code.
I'll post it as soon as possible.

By the way, I have short test and found some problem...

# 2.6.22.orig : default
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  2.22 (usecs) (0 errors / 4510497 iterations)
CPU  1:  2.11 (usecs) (0 errors / 4729160 iterations)
CPU  2:  2.14 (usecs) (0 errors / 4669828 iterations)
CPU  3:  2.14 (usecs) (0 errors / 4663743 iterations)

# 2.6.22.orig : nojitter
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  0.14 (usecs) (0 errors / 70652818 iterations)
CPU  1:  0.14 (usecs) (0 errors / 71315157 iterations)
CPU  2:  0.15 (usecs) (253 errors / 68629496 iterations)
CPU  3:  0.15 (usecs) (235 errors / 68783716 iterations)

# 2.6.22.orig : nolwsys
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  3.30 (usecs) (0 errors / 3028985 iterations)
CPU  1:  3.29 (usecs) (0 errors / 3042175 iterations)
CPU  2:  3.34 (usecs) (0 errors / 2992885 iterations)
CPU  3:  3.33 (usecs) (0 errors / 3001872 iterations)


# clocksource (Bob's) : default
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  4.66 (usecs) (0 errors / 2145680 iterations)
CPU  1:  4.65 (usecs) (493 errors / 2148438 iterations)
CPU  2:  4.63 (usecs) (668 errors / 2159461 iterations)
CPU  3:  4.62 (usecs) (654 errors / 2163997 iterations)

# clocksource (Bob's) : nojitter
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  0.14 (usecs) (0 errors / 70945550 iterations)
CPU  1:  0.14 (usecs) (470 errors / 71640889 iterations)
CPU  2:  0.14 (usecs) (664 errors / 70960917 iterations)
CPU  3:  0.14 (usecs) (571 errors / 70956121 iterations)

# clocksource (Bob's) : nolwsys
[root@gettimeofday]# ./run.sh
nr_cpus = 4
CPU  0:  2.88 (usecs) (0 errors / 3475147 iterations)
CPU  1:  2.88 (usecs) (0 errors / 3474881 iterations)
CPU  2:  2.96 (usecs) (0 errors / 3382229 iterations)
CPU  3:  2.97 (usecs) (0 errors / 3371004 iterations)


These result shows that the clocksource's default (new
fsys_gettimeofday) doesn't work well.
  - time goes backward (="error") even if it use cmpxchg
  - worse scalability than normal gettimeofday

Just FYI.


Thanks,
H.Seto
