From: Sylvain Jeaugey <sylvain.jeaugey@bull.net>
Date: Fri, 26 Sep 2003 07:17:57 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106456075800832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Sep 2003, Hubertus Franke wrote:

> Again, I see cpusets and CKRM as addressing two orthogonal issues wrt to 
> cpu's
> 
> cpusets  (partitioning in space)   with hierarchies
> CKRM  (time partitioning)         how much of  time does a class get...
We do agree. We took a look at CKRM and that is the conclusion we 
achieved. At first sight, it could look like the goal are the same -and in 
some points it is- but the two approaches are different. It looks 
like it would be better to combine them rather to try to merge them.

Sylvain

