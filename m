From: Steve Neuner <srn@sgi.com>
Date: Mon, 05 May 2003 15:46:49 +0000
Subject: Re: [Linux-ia64] benchmarking results
Message-Id: <marc-linux-ia64-105590723705636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705621@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705621@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Maybe in all the cases I can see NUMA architectures and not find references
> related to what kind of scheduler was used older sched, O(1) or HT? 

Hi Adriano,

On the SGI Altix system we've been getting good results with the
O(1) scheduler.  

> The limits of the bricks for SMP are 4 proc, how could I assume linear
> scalability for 8 proc having memory latency accesing the others bricks
> through R-Brick maybe?

There are many factors that can affect getting good "scalability" beyond
8p (e.g., hardware design, kernel scalability, user v. kernel workload, 
user app scalability, I/O subsystem, etc) -- having a good hardware design 
with a fast system interconnect is essential.

--steve

