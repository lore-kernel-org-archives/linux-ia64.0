From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Fri, 10 Aug 2001 13:15:56 +0000
Subject: [Linux-ia64] ping(8) faster than light (do_get_fast_time) (fwd)
Message-Id: <marc-linux-ia64-105590698805052@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have encountered the following strange problem that is related
to the RedHat bug

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id7485

A "ping localhost" on RedHat 7.1 will generate the warning

Warning: time of day goes back, taking countermeasures.

Tracing ping(8) with tcpdump shows that echo request and echo reply
packets have exactly the same time stamp.

The "RELNOTES" file of the RedHat iputils package says

* By Pekka Savola <pekkas@netcore.fi>
  - SIOCGSTAMP/SO_TIMESTAMP are sensitive to bug in kernel.
    When get_fast_time != gettimeofday (f.e. timestampless x86),
    returned stamp can be out of sync with gettimeofday.
    Workaround is not to use SIOCGSTAMP/SO_TIMESTAMP on such systems.

It appears that this is actually the reason for the above problem.

The deeper reason is that on IA64, *do_get_fast_time() equals
do_normal_gettime(), which simply returns xtime. On other architectures
do_get_fast_time() is set to do_gettimeofday() in time_init(), which
avoids the problem.

1) Is do_gettimeofday () too slow on IA64 to use it for
   do_get_fast_time() ?

2) If yes, would it be possible to susbtitute a do_get_fast_time()
   that is faster and less accurate than do_gettimeofday(), but still
   better than do_normal_gettime() ?

3) If no, the ping(8) program on IA64 should IMO be changed to not use
   SO_TIMESTAMP (equivalent to "ping -U" with the RH7.1 ping).

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113








