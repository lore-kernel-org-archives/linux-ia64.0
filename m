From: Hubertus Franke <frankeh@watson.ibm.com>
Date: Fri, 26 Sep 2003 13:29:57 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106458305921458@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sylvain Jeaugey wrote:

>>>With cpusets each application can ask the kernel for 5 cpus
>>>(or a wrapper that invokes the application can do so), and then
>>>the application can happily divide its work between virtual cpus
>>>0, 1, 2, 3, 4 (using sched_setaffinity()).  The kernel can be smart
>>>and provide different physical cpus for each of the cpusets.
>>>      
>>>
>Actually, the intelligence is located in the wrapper application. The 
>kernel part of cpusets is given absolute masks. The virtualization is 
>located in the fact that calls to sched_setaffinity() are interpreted 
>within the cpuset, and that /proc/cpuinfo is also modified to reflect 
>available CPUs.
>
>  
>
Exactly ....   virtualization of the virtual cpu number is the trick to 
isolation from a code base
perspective .... it

>>In this case, the applications can get all of current affinity info by
>>calling sched_getaffinity(). Thus, the applications can schedule the
>>processes to different cpus without bothering kernel.
>>    
>>
>The problem is not only to run on a different CPU. We want that the used 
>CPU is decided by the admin and not the application. Otherwise you would 
>have no control on it. It could have been a solution for applications we 
>write like MPI (and that is the first thing we did).
>But we wanted to create something that could be a little united for all 
>applications, without rewrite of applications. We add a lot of customized 
>apps, each having been hacked to do something like this, but this resulted 
>in a huge mess, lots of different configuration files, and no 
>interoperability. By pushing it in the kernel, everything is _simple_ and 
>_united_.
>
>Sylvain
>
>
>  
>
Yipp, the lesson from the MPI ( I was involved in that as the 
implementer of the first IBM MPI implementation
for the IBM SP2) is that these abstractions (such as communicators, 
topologies) really mattered. It allowed application
writers to code algorithms without worrying how many cpu's which cpu, 
who's the next physical neighbor.
It stayed at the virtual level.
cpusets are the same .

Enough on this topic now .. :-)

-- Hubertus Franke  (CKRM  team)

