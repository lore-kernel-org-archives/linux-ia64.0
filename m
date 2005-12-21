From: "Truong, Dan" <dan.truong@hp.com>
Date: Wed, 21 Dec 2005 22:39:26 +0000
Subject: RE: [perfmon] Re: quick overview of the perfmon2 interface
Message-Id: <3C87FFF91369A242B9C9147F8BD0908A02C69454@cacexc04.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com>
In-Reply-To: <20051219113140.GC2690@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, "Eranian, Stephane" <stephane.eranian@hp.com>
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Just a couple of cents here to support Stephane's design :)


> Why would one want to change the format of the sampling buffer?

The idea is to allow user custom formats for one, and allow Exotic
architectures for second.

Say you want to reduce the volume of data passed to the application And
stored in the buffers, you can then do some pre-processing Inside the
kernel via a custom module.

You can also return more complex data than just PMU registers, think
Call stacks or other OS related information that can complement the The
PMU data.

Some data can be returned vis pseudo PMU registers (i.e. extentions),
Like the interval timer, PID/TID, etc. but for more complex and less
Synchronous data you may end up needed a more powerfull buffer format
With headers etc.

Another issue can be if hardware buffer support is provided. The
hardware Buffer support will not allow collection of pseudo-counters
which are Supported by software, so again the packaging may not be as
linear as A repeated sequence of counters...

With Stephane we had discussed this buffer format, and came to the
Conclusion that flexibility there will avoid hitting the wall.

You don't know what tomorrow is made of (yet)...



> > 	The PMU register description is implemented by a kernel
pluggable
> 
> Is that option important, or likely to be useful?  Are you sure there 
> isn't some overdesign here?

It will allow bringup of new PMUs on new architectures more easily, and
simpler distribution of support. It will also allow CPU designers to
create custom drivers that support non-public features to debug the
CPUs.



> hm.  I'm surprised at such a CPU-centric approach.  I'd have expected 
> to see a more task-centric model.

Both per-thread and system-wide measurments are useful.

Systemwide is used to evaluate the beavior of the whole system when
tuning a large load (think TPC-C, SpecWeb, SpecJapp...) Per thread is
used for specific application/thread tuning and self monitoring. Also
per-thread monitoring is not always adviseable, for example when there
Are a large number of threads loading the system, adding that many
monitors will impact the system performance, so you will want to measure
per CPU.

> So the kernel buffers these messages for the read()er.  How does it 
> handle the case of a process which requests the messages but never 
> gets around to read()ing them?

Stephane, I would assume that the monitoring session attached to
The buffer returning the message just stalls. If there is multiplexing,
Will coming back to that stalled buffer stall all the multiplexed
Sessions? I would assume so.



> Why would one want to randomise the PMD after an overflow?

Everybody does it :) Helps generate an un-biased picture.



> I think the usefulness of this needs justification.  CPUs are updated 
> all the time, and we release new kernels all the time to exploit the 
> new CPU features.  What's so special about performance counters that 
> they need such special treatment?

The PMU is not fully architected usually. Nothing prevents a
Model to be shipped with PMU upgrades.
Also the PMU can be used by architects for validation of the designs.
Easier early access to the functionalities helps.

The PMU is a direct evolution of the debug counters that were used
To debug CPUs but not available for general use. They are still used
In that fashion too, and a main reason they exist.


Cheers,

Dan-
