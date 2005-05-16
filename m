From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 16 May 2005 19:29:27 +0000
Subject: Re: IA64 implementation of timesource for new time of day subsystem
Message-Id: <17032.62615.750699.18847@napali.hpl.hp.com>
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
	<Pine.LNX.4.62.0505161219570.2158@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0505161219570.2158@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, Tim Schmielau <tim@physik3.uni-rostock.de>, George Anzinger <george@mvista.com>, albert@users.sourceforge.net, Ulrich Windl <ulrich.windl@rz.uni-regensburg.de>, Dominik Brodowski <linux@dominikbrodowski.de>, David Mosberger <davidm@hpl.hp.com>, Andi Kleen <ak@suse.de>, paulus@samba.org, schwidefsky@de.ibm.com, keith maanthey <kmannth@us.ibm.com>, Chris McDermott <lcm@us.ibm.com>, Max Asbock <masbock@us.ibm.com>, mahuja@us.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Darren Hart <darren@dvhart.com>, "Darrick J. Wong" <djwong@us.ibm.com>, Anton Blanchard <anton@samba.org>, donf@us.ibm.com, mpm@selenic.com, benh@kernel.crashing.org, linux-ia64@vger.kernel.org

>>>>> On Mon, 16 May 2005 12:24:08 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:

  Christoph> Other IA64 vendors will see that their timer performance
  Christoph> drops significantly after the new timer subsystem is
  Christoph> in. IBM no longer has IA64 systems that rely on ITC?

Would that somehow make it ok to break existing and working code?

	--david
