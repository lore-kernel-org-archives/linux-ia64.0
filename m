From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 25 Sep 2003 18:49:52 +0000
Subject: RE: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106451631727404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You could also do a big chunk of this by allowing normal 
> privledge users
> to sched_setaffinity() a *subset* of their current allowed 
> CPU set, but
> not expand it.  sched_setaffinity() isn't *that* old of an 
> interface, so
> I'm not sure why you can't just change the application at 
> this point.  

Because you need virtual cpu numbers.  Suppose I have a 16-way
system, and *two* applications that know nothing about each other,
but each happens to want 5 cpus to run.

With cpusets each application can ask the kernel for 5 cpus
(or a wrapper that invokes the application can do so), and then
the application can happily divide its work between virtual cpus
0, 1, 2, 3, 4 (using sched_setaffinity()).  The kernel can be smart
and provide different physical cpus for each of the cpusets.

-Tony
