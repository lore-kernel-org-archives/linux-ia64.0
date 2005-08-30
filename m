From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 30 Aug 2005 15:45:47 +0000
Subject: Re: [PATCH 2.6.13 0/7] MCA/INIT: summary
Message-Id: <20050830103831.A39952@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050830050414.7997.92549.sendpatchset@kao2.melbourne.sgi.com>
In-Reply-To: <20050830050414.7997.92549.sendpatchset@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 30 Aug 2005, Keith Owens wrote:

> Now that MCA/INIT is recoverable, we will have to address the SCSI
> timeouts that occur if interrupts are disabled for long periods.  MCA
> can disable interrupts for up to 20 seconds while it does the
> rendezvous.  On resume, the timer code tries to bring jiffies in sync
> with itc, time runs too fast and we get spurious timeouts.  There is no
> point in recovering from MCA if the disk dies as a side effect of the
> lost interrupts.

I believe you'll find a similar problem with IEEE 1394, at 10 seconds.
See drivers/ieee1394/ieee1394_core.c, the hpsb_send_packet() routine
in particular.  There we find:

	if (!packet->no_waiter || packet->expect_response) {
		atomic_inc(&packet->refcnt);
		/* Set the initial "sendtime" to 10 seconds from now, to
		   prevent premature expiry.  If a packet takes more than
		   10 seconds to hit the wire, we have bigger problems :) */
		packet->sendtime = jiffies + 10 * HZ;
		skb_queue_tail(&host->pending_packet_queue, packet->skb);
	}

Brent

-- 
Brent Casavant                          If you had nothing to fear,
bcasavan@sgi.com                        how then could you be brave?
Silicon Graphics, Inc.                    -- Queen Dama, Source Wars
