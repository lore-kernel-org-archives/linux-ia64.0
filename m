From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 25 Feb 2005 23:01:07 +0000
Subject: RE: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <01EF044AAEE12F4BAAD955CB750649430313447C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <> wrote on Friday, February 25, 2005 2:47 PM:

>>>>>> On Fri, 25 Feb 2005 13:15:05 -0800, "Seth, Rohit"
>>>>>> <rohit.seth@intel.com> said: 
> 
>   Rohit> For pinning a task (or set of tasks) to same core or multiple
>   Rohit> cores, you only need package id and core id.  The thread
>   Rohit> information is really not required.  Right?
> 
> Yeah, that's true.  At least I can't come up with a good reason of
> wanting to know which thread exactly you're running on.  Having said
> that, from a user-perspective, looking at two entries in /proc/cpuinfo
> and seeing that the socket id/core id are the same and only the thread
> ids are different probably would give me more of a warm and fuzzy
> feeling.
> 

Well, I was only trying to evaluate what is the most optimal set of
entries for /proc/cpuinfo.  I'm sure there are other entries
present...for precisely the same reason that you listed.

>   Rohit> AFAIK, an easy way for apps (for licensing etc.) to find out
>   Rohit> if and how many LEUs are present without doing any other
>   Rohit> calculation.
> 
> Yeah, I guess "MAX(thread_id) + 1" does count as a "calculation".  And
> I thought computers where good at that... ;-)
> 


Siblings have no direct relationship with thread_id.  Tids(threads ids)
are not guranteed to be contiguous.  

-rohit
