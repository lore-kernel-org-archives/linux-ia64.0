From: Hubertus Franke <frankeh@watson.ibm.com>
Date: Thu, 25 Sep 2003 13:19:05 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106449620531532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Paul Jackson wrote:

>>Well, the thing is, CKRM essentially has the cross-resource bits and
>>makes up some group that can be joined and departed from and inherited
>>and so on with all the right knobs ...
>>    
>>
>
>The hierarchies don't correspond, or do so only accidentally.
>
>That is, cpusets, as proposed, have a hierarchy such that one
>cpuset is the child of another if one cpuset describes a subset
>of another's CPUs.
>
>At first blush, I don't see a hierarchy of CKRM Classes, rather
>just a flat space, say Gold, Silver and Bronze.
>  
>
Paul, yes CKRM classes at this point are flat, we looked initially at 
hierarchies and
determined that for the first release might add a lot of complexity with 
questionable
benefits for the community at large. So we left hierarchies out.
Based on the general community feedback we might have to revisit this issue.

Again, I see cpusets and CKRM as addressing two orthogonal issues wrt to 
cpu's

cpusets  (partitioning in space)   with hierarchies
CKRM  (time partitioning)         how much of  time does a class get...

-- Hubertus Franke   ( CKRM team )

