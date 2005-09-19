From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 19 Sep 2005 19:06:32 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F046E616C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>Ok then we can simply remove the time_interpolator_reset() call from 
>my patch. Then the self-tuning interpolator logic will compensate for the 
>difference over time.

Can you provide a bit more detail in the form of a concrete example
or two.  Suppose I stop the system (e.g. by entering a debugger) and
after poking around for sixty seconds, I restart the OS.

How long does it take for the interpolator to compensate for the
lost minute?

What is the relative rate of time while this compensation happens?

Does it make a difference if NTP is running?

-Tony
