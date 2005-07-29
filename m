From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 29 Jul 2005 01:25:22 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <42E98582.2080406@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507282348.j6SNmLg02429@unix-os.sc.intel.com>
In-Reply-To: <200507282348.j6SNmLg02429@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

>Nick Piggin wrote on Thursday, July 28, 2005 4:35 PM
>
>>Wake balancing provides an opportunity to provide some input bias
>>into the load balancer.
>>
>>For example, if you started 100 pairs of tasks which communicate
>>through a pipe. On a 2 CPU system without wake balancing, probably
>>half of the pairs will be on different CPUs. With wake balancing,
>>it should be much better.
>>
>
>Shouldn't the pipe code use synchronous wakeup?
>
>

Well pipes are just an example. It could be any type of communication.
What's more, even the synchronous wakeup uses the wake balancing path
(although that could be modified to only do wake balancing for synch
wakeups, I'd have to be convinced we should special case pipes and not
eg. semaphores or AF_UNIX sockets).

>
>>I hear you might be having problems with recent 2.6.13 kernels? If so,
>>it would be really good to have a look that before 2.6.13 goes out the
>>door.
>>
>
>Yes I do :-(, apparently bumping up cache_hot_time won't give us the
>performance boost we used to see.
>
>
OK there are probably a number of things we can explore depending on
what are the symptoms (eg. excessive idle time, bad cache performance).

Unfortunately it is kind of difficult to tune 2.6.13 on the basis of
2.6.12 results - although that's not to say it won't indicate a good
avenue to investigate.


Send instant messages to your online friends http://au.messenger.yahoo.com 
