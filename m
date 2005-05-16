From: Chris Friesen <cfriesen@nortel.com>
Date: Mon, 16 May 2005 15:30:46 +0000
Subject: Re: IA64 implementation of timesource for new time of day subsystem
Message-Id: <4288BCA6.9000002@nortel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1116029796.26454.2.camel@cog.beaverton.ibm.com> <1116029872.26454.4.camel@cog.beaverton.ibm.com> <1116029971.26454.7.camel@cog.beaverton.ibm.com> <1116030058.26454.10.camel@cog.beaverton.ibm.com> <1116030139.26454.13.camel@cog.beaverton.ibm.com> <Pine.LNX.4.62.0505141251490.18681@schroedinger.engr.sgi.com> <428722E3.6040202@superbug.co.uk> <20050515101705.GC26242@wotan.suse.de>
In-Reply-To: <20050515101705.GC26242@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: James Courtier-Dutton <James@superbug.co.uk>, Christoph Lameter <clameter@engr.sgi.com>, john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, Tim Schmielau <tim@physik3.uni-rostock.de>, George Anzinger <george@mvista.com>, albert@users.sourceforge.net, Ulrich Windl <ulrich.windl@rz.uni-regensburg.de>, Dominik Brodowski <linux@dominikbrodowski.de>, David Mosberger <davidm@hpl.hp.com>, paulus@samba.org, schwidefsky@de.ibm.com, keith maanthey <kmannth@us.ibm.com>, Chris McDermott <lcm@us.ibm.com>, Max Asbock <masbock@us.ibm.com>, mahuja@us.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Darren Hart <darren@dvhart.com>, "Darrick J. Wong" <djwong@us.ibm.com>, Anton Blanchard <anton@samba.org>, donf@us.ibm.com, mpm@selenic.com, benh@kernel.crashing.org, linux-ia64@vger.kernel.org

Andi Kleen wrote:
>>Will this mean that Linux will have a monotonic time source?
> 
> 2.6 has had one for a long time (posix_gettime(CLOCK_MONOTONIC))

I think that's clock_gettime(), no?

Chris
