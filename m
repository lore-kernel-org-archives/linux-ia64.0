From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 25 Feb 2005 21:15:05 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB75064943031342C3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <> wrote on Friday, February 25, 2005 12:47 PM:

>>>>>> On Fri, 25 Feb 2005 12:12:34 -0800, "Seth, Rohit"
>>>>>> <rohit.seth@intel.com> said: 
> 
>   Rohit> "Cpu Cores" identifying the number of cores in a physical
>   Rohit> package is present in x86_64 and not there in i386 tree.
> 
>   Rohit> Will following work:
> 
>   Rohit> Physical id: Identifying the unique physical package id for
>   LEU Rohit> Core id: Identifying the unique core id on that specific
>   physical Rohit> package
>   Rohit> Siblings: Identifying the total number LEUs on that physical
> package. 
> 
> Well, I think it would be useful if we can look at /proc/cpuinfo and
> get a mapping from Linux CPU number to "topological address" (socket
> id, core id, thread id).  With that plus taskset, it would be very
> easy to run a test with, for example, two processes pinned to the two
> threads on the same core or pinned to separate cores, etc.
> 

For pinning a task (or set of tasks) to same core or multiple cores, you
only need package id and core id.  The thread information is really not
required.  Right?

>   Rohit> Siblings is the one that apps have already started using on
> i386. 
> 
> What is it being used for?
>

AFAIK, an easy way for apps (for licensing etc.) to find out if and how
many LEUs are present without doing any other calculation.

-rohit
