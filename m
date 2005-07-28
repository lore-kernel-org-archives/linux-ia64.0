From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 28 Jul 2005 23:48:20 +0000
Subject: RE: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <200507282348.j6SNmLg02429@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <42E96B8C.6010005@yahoo.com.au>
References: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
In-Reply-To: <200507282308.j6SN8Tg01993@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, July 28, 2005 4:35 PM
> Wake balancing provides an opportunity to provide some input bias
> into the load balancer.
> 
> For example, if you started 100 pairs of tasks which communicate
> through a pipe. On a 2 CPU system without wake balancing, probably
> half of the pairs will be on different CPUs. With wake balancing,
> it should be much better.

Shouldn't the pipe code use synchronous wakeup?


> I hear you might be having problems with recent 2.6.13 kernels? If so,
> it would be really good to have a look that before 2.6.13 goes out the
> door.

Yes I do :-(, apparently bumping up cache_hot_time won't give us the
performance boost we used to see.

- Ken

