From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 25 Nov 2003 18:24:30 +0000
Subject: Re: pal/power_info for real?
Message-Id: <marc-linux-ia64-106978478405715@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106975147501700@msgid-missing>
In-Reply-To: <marc-linux-ia64-106975147501700@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-11-25 at 02:09, Duraid Madina wrote:
> 	Is this correct? Two power levels, with different entry latencies, but 
> the same power consumption?

  Yep, power level 0 is light_halt and 2 is halt2.  I can't really
comment on the power consumption, but presumably they're shutting down
different portions of the chip.  I see the same thing on my boxes.  Note
that these are all halt state power consumptions, not full running power
consumption.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

