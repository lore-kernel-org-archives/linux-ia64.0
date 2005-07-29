From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 10:52:11 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050729105211.GA23355@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050728090948.GA24222@elte.hu> <200507281914.j6SJErg31398@unix-os.sc.intel.com> <20050729070447.GA3032@elte.hu> <20050729070702.GA3327@elte.hu> <1122628675.14892.9.camel@twins>
In-Reply-To: <1122628675.14892.9.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> code like that always makes me think of duffs-device
>   http://www.lysator.liu.se/c/duffs-device.html
> 
> although it might be that the compiler generates better code from the 
> current incarnation; just my .02 ;-)

yeah, will do that. First wanted to see whether it's worth it.

	Ingo
