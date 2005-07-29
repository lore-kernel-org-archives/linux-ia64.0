From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 16:40:11 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <20050729164011.GA12138@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <42E9ED47.1030003@yahoo.com.au>
In-Reply-To: <42E9ED47.1030003@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Chen, Kenneth W wrote:
> >Nick Piggin wrote on Thursday, July 28, 2005 7:01 PM
> 
> >This clearly outlines an issue with the implementation.  Optimize for one
> >type of workload has detrimental effect on another workload and vice versa.
> >
> 
> Yep. That comes up fairly regularly when tuning the scheduler :(

in this particular case we can clearly separate the two workloads 
though: CPU-overload (Ken's benchmark) vs. half-load (3-task tbench). So 
by checking for migration target/source idleness we can have a hard 
separator for wakeup balancing. (whether it works out for both types of 
workloads remains to be seen)

	Ingo
