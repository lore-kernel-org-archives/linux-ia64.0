From: john stultz <johnstul@us.ibm.com>
Date: Mon, 16 May 2005 18:55:42 +0000
Subject: Re: IA64 implementation of timesource for new time of day subsystem
Message-Id: <1116269742.26990.74.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1116029796.26454.2.camel@cog.beaverton.ibm.com>
	 <1116029872.26454.4.camel@cog.beaverton.ibm.com>
	 <1116029971.26454.7.camel@cog.beaverton.ibm.com>
	 <1116030058.26454.10.camel@cog.beaverton.ibm.com>
	 <1116030139.26454.13.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.62.0505141251490.18681@schroedinger.engr.sgi.com>
	 <1116264858.26990.39.camel@cog.beaverton.ibm.com>
	 <Pine.LNX.4.62.0505161100240.1653@schroedinger.engr.sgi.com>
	 <1116269136.26990.67.camel@cog.beaverton.ibm.com>
In-Reply-To: <1116269136.26990.67.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Tim Schmielau <tim@physik3.uni-rostock.de>, George Anzinger <george@mvista.com>, albert@users.sourceforge.net, Ulrich Windl <ulrich.windl@rz.uni-regensburg.de>, Dominik Brodowski <linux@dominikbrodowski.de>, David Mosberger <davidm@hpl.hp.com>, Andi Kleen <ak@suse.de>, paulus@samba.org, schwidefsky@de.ibm.com, keith maanthey <kmannth@us.ibm.com>, Chris McDermott <lcm@us.ibm.com>, Max Asbock <masbock@us.ibm.com>, mahuja@us.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Darren Hart <darren@dvhart.com>, "Darrick J. Wong" <djwong@us.ibm.com>, Anton Blanchard <anton@samba.org>, donf@us.ibm.com, mpm@selenic.com, benh@kernel.crashing.org, linux-ia64@vger.kernel.org

On Mon, 2005-05-16 at 11:45 -0700, john stultz wrote:
> All you need is to do is define  implement an ia64 version of
> arch_update_vsyscall_gtod() which can then export the values passed to
> it in whatever form you desire so it can be used by the fastcall.


Sorry, that first sentence wasn't complete, I went to go look up the
reference and got distracted with something else.

It should be "All you need to do is define NEWTOD_VSYSCALL and
implement.."

time for more coffee :)
-john


