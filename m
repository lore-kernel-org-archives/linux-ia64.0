From: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
Date: Tue, 17 May 2005 08:05:08 +0000
Subject: Re: IA64 implementation of timesource for new time of day subsystem
Message-Id: <4289C1D4.5666.6DBB9A@rkdvmks1.ngate.uni-regensburg.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0505161219570.2158@schroedinger.engr.sgi.com>
In-Reply-To: <17032.62615.750699.18847@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: john stultz <johnstul@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, Tim Schmielau <tim@physik3.uni-rostock.de>, George Anzinger <george@mvista.com>, albert@users.sourceforge.net, Ulrich Windl <ulrich.windl@rz.uni-regensburg.de>, Dominik Brodowski <linux@dominikbrodowski.de>, Andi Kleen <ak@suse.de>, paulus@samba.org, schwidefsky@de.ibm.com, keith maanthey <kmannth@us.ibm.com>, Chris McDermott <lcm@us.ibm.com>, Max Asbock <masbock@us.ibm.com>, mahuja@us.ibm.com, Nishanth Aravamudan <nacc@us.ibm.com>, Darren Hart <darren@dvhart.com>, "Darrick J. Wong" <djwong@us.ibm.com>, Anton Blanchard <anton@samba.org>, donf@us.ibm.com, mpm@selenic.com, benh@kernel.crashing.org, linux-ia64@vger.kernel.org

On 16 May 2005 at 12:29, David Mosberger wrote:

> >>>>> On Mon, 16 May 2005 12:24:08 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:
> 
>   Christoph> Other IA64 vendors will see that their timer performance
>   Christoph> drops significantly after the new timer subsystem is
>   Christoph> in. IBM no longer has IA64 systems that rely on ITC?
> 
> Would that somehow make it ok to break existing and working code?

AFAIR the design goal was not to make a new time implementation, but to make a 
more precise one ;-)

Regards,
Ulrich

