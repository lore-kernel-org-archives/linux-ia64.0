From: Hubertus Franke <frankeh@watson.ibm.com>
Date: Fri, 26 Sep 2003 12:57:58 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106458116219336@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sylvain Jeaugey wrote:

>On Thu, 25 Sep 2003, Hubertus Franke wrote:
>
>  
>
>>Again, I see cpusets and CKRM as addressing two orthogonal issues wrt to 
>>cpu's
>>
>>cpusets  (partitioning in space)   with hierarchies
>>CKRM  (time partitioning)         how much of  time does a class get...
>>    
>>
>We do agree. We took a look at CKRM and that is the conclusion we 
>achieved. At first sight, it could look like the goal are the same -and in 
>some points it is- but the two approaches are different. It looks 
>like it would be better to combine them rather to try to merge them.
>
>Sylvain
>
>
>  
>
Correct.  These are both worthwhile efforts and they do different things.
A combination of  both at some point (not now) should be investigated.
On the CPU front, which cpusets at this point provide its simply orthogonal.

cpusets provide you means to lock process down to cpus through some
abstraction/virtual layer that does not determine the exact cpu but 
guarantees that
some cpu will be choosen to represent that number.

This is analogous to MPI applications which provide communicators which 
effectively
are "cpusets" in the broader sense. On top of that they provide topology 
information
as such..

Actually I don't see why CKRM can't enforce class shares on top of cpu sets.
They simply don't need to know about each others presense. CKRM through
its loadbalancing algorithm enforces shares for SMPs while at the same time
observes cpu_affinity constraints, which effectively cpusets boil down 
to ....

So  "combine" is the correct wording here....

-- Hubertus Franke   (CKRM team)

