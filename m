From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 28 Jul 2005 23:34:36 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <42E96B8C.6010005@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> What sort of workload needs SD_WAKE_AFFINE and SD_WAKE_BALANCE?
> SD_WAKE_AFFINE are not useful in conjunction with interrupt binding.
> In fact, it creates more harm than usefulness, causing detrimental
> process migration and destroy process cache affinity etc.  Also
> SD_WAKE_BALANCE is giving us performance grief with our industry
> standard OLTP workload.
> 

The periodic load balancer basically makes completely undirected,
random choices when picking which tasks to move where.

Wake balancing provides an opportunity to provide some input bias
into the load balancer.

For example, if you started 100 pairs of tasks which communicate
through a pipe. On a 2 CPU system without wake balancing, probably
half of the pairs will be on different CPUs. With wake balancing,
it should be much better.

I've also been told that it impoves IO efficiency significantly -
obviously that depends on the system and workload.

> To demonstrate the problem, we turned off these two flags in the cpu
> sd domain and measured a stunning 2.15% performance gain!  And deleting
> all the code in the try_to_wake_up() pertain to load balancing gives us
> another 0.2% gain.
> 
> The wake up patch should be made simple, just put the waking task on
> the previously ran cpu runqueue.  Simple and elegant.
> 
> I'm proposing we either delete these two flags or make them run time
> configurable.
> 

There have been lots of changes since 2.6.12. Including less aggressive
wake balancing.

I hear you might be having problems with recent 2.6.13 kernels? If so,
it would be really good to have a look that before 2.6.13 goes out the
door.

I appreciate all the effort you're putting into this!

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
