From: Rik van Riel <riel@redhat.com>
Date: Thu, 25 Sep 2003 16:06:54 +0000
Subject: Re: [ckrm-tech] Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106450615513424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Sep 2003, Hubertus Franke wrote:

> Paul, yes CKRM classes at this point are flat, we looked initially at
> hierarchies and determined that for the first release might add a lot of
> complexity with questionable benefits for the community at large. So we
> left hierarchies out. Based on the general community feedback we might
> have to revisit this issue.

I'm not sure we will ever need hierarchies in the kernel.

For all intents and purposes, we might be able to emulate
them in userspace by having a daemon interpret the class
resource usage statistics and adjusting priorities
dynamically ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

