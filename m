From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 10 Aug 2001 15:34:26 +0000
Subject: Re: [Linux-ia64] ping(8) faster than light (do_get_fast_time) (fwd)
Message-Id: <marc-linux-ia64-105590698805054@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805052@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805052@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Aug 2001 15:15:56 +0200 (CEST), Martin Wilck <Martin.Wilck@fujitsu-siemens.com> said:

  Martin> The deeper reason is that on IA64, *do_get_fast_time()
  Martin> equals do_normal_gettime(), which simply returns xtime.

This distinction doesn't make sense on ia64 because there is no
(slow) gettimeofday() to begin with.

  Martin> 1) Is do_gettimeofday () too slow on IA64 to use it for
  Martin> do_get_fast_time() ?

I have no idea what you mean here.  On ia64 do_gettimeofday() returns
xtime plus an itc based time offset.  The kernel is careful to return
only monotonically increasing time values, even in cases where the
ITCs in different CPUs are not perfectly synchronized.

  Martin> 3) If no, the ping(8) program on IA64 should IMO be changed
  Martin> to not use SO_TIMESTAMP (equivalent to "ping -U" with the
  Martin> RH7.1 ping).

We should first find out what the real problem is.  What timestamps
are present at the time ping is complaining?  If the earlier timestamp
is bigger than the later one, there is a bug somewhere.  If they're
equal (unlikely, given that we do ITC-based interpolation), ping
shouldn't complain.

	--david

