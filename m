From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 14 Oct 2003 05:23:39 +0000
Subject: Re: [PATCH_TAKE_2] now < last_tick problem
Message-Id: <marc-linux-ia64-106610905400509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106575925709435@msgid-missing>
In-Reply-To: <marc-linux-ia64-106575925709435@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Oct 2003 09:06:21 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> That was my point, sorry.

  Ian> do_gettimeofday() does

  Ian>  while (1) {
  Ian>                seq = read_seqbegin(&xtime_lock);
  Ian>                {
  Ian>                        old = last_nsec_offset;
  Ian>                        offset = time_interpolator_get_offset();
  Ian>                        sec = xtime.tv_sec;
  Ian>                        nsec = xtime.tv_nsec;
  Ian>                }
  Ian>                if (unlikely(read_seqretry(&xtime_lock, seq)))
  Ian>                        continue;
  Ian>  ... and so on ...
  Ian> }

  Ian> Previously, if that read_seqbegin was some kind of irq save lock, then
  Ian> time_interpolator_get_offset() (which is itc_get_offset()) should
  Ian> never have been interrupted (especially by the timer interrupt), and
  Ian> the warning message (now < last_tick) meant something was wrong.
  Ian> Using synchronisation, it's probable that itc_get_offset() will be
  Ian> interrupted every now and then, but do_gettimeofday() will keep
  Ian> retrying it till read_seqretry informs it that read the right values.

  Ian> So the warning message in itc_get_offset isn't really needed?

Hmmh, I seem to have misremembered the code.  I thought we updated
last_nsec_offset _before_ read_seqretry(), but that's not the case.  I
think you may be right that we can simply delete the (bogus)
consistency-check.  May want to add a comment about that, though.

	--david
