From: Jes Sorensen <jes@trained-monkey.org>
Date: Fri, 17 Oct 2003 15:23:39 +0000
Subject: Re: [BUG, RFC] do_gettimeofday going backwards
Message-Id: <marc-linux-ia64-106640457019159@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106497008007151@msgid-missing>
In-Reply-To: <marc-linux-ia64-106497008007151@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David> Then your time-interpolator is broken.  As I have expained on
David> previous occasions (in particular in a mail to Jes),
David> last_nsec_offset must not be _cleared_ on a timer-tick.
David> Instead, it needs to be decremented by the timer tick period.
David> So in your case, last_nsec_offset would decrease from 1099000
David> to 99000.

Thats how my implementation works for 2.4 as well, however according
to what I have heard they are still seeing problems with it going
backwards, just not as frequently as before.

Cheers,
Jes
