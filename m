From: Shailabh Nagar <nagar@watson.ibm.com>
Date: Thu, 25 Sep 2003 20:50:51 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106452313403787@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Shailabh Nagar wrote:

> 
> CKRM shares some aspects of the first objective i.e. it also seeks 
> performance isolation for arbitrary groups of processes (classes) too 
> but differs in that it
> - uses scheduler modifications to achieve isolation
> - has a quantitative measures for how much resource is used

Let me modify that since CPUSETs also provides a coarse-grain (#cpus) 
quantitative measure.

CKRM allows % of the total resource (cpu ticks, mem pages etc.) to be 
specified and is consequently at a finer granularity.




