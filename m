From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Mon, 13 Oct 2003 23:06:21 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106608640432242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 13, 2003 at 11:17:06AM -0700, David Mosberger wrote:
> You do realize that xtime_lock is NOT a lock at all?  Seqlock is a
> scheme for lock-free synchronization.

That was my point, sorry.

do_gettimeofday() does 

 while (1) {
                seq = read_seqbegin(&xtime_lock);
                {
                        old = last_nsec_offset;
                        offset = time_interpolator_get_offset();
                        sec = xtime.tv_sec;
                        nsec = xtime.tv_nsec;
                }
                if (unlikely(read_seqretry(&xtime_lock, seq)))
                        continue;
  ... and so on ...
 }

Previously, if that read_seqbegin was some kind of irq save lock, then
time_interpolator_get_offset() (which is itc_get_offset()) should
never have been interrupted (especially by the timer interrupt), and
the warning message (now < last_tick) meant something was wrong.
Using synchronisation, it's probable that itc_get_offset() will be
interrupted every now and then, but do_gettimeofday() will keep
retrying it till read_seqretry informs it that read the right values.

So the warning message in itc_get_offset isn't really needed?

-i
