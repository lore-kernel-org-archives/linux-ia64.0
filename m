From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 29 Jul 2005 02:01:14 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <42E98DEA.9090606@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290153.j6T1rYg03861@unix-os.sc.intel.com>
In-Reply-To: <200507290153.j6T1rYg03861@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:

>Nick Piggin wrote on Thursday, July 28, 2005 6:46 PM
>
>>I'd like to try making them less aggressive first if possible.
>>
>
>Well, that's exactly what I'm trying to do: make them not aggressive
>at all by not performing any load balance :-)  The workload gets maximum
>benefit with zero aggressiveness.
>
>

Unfortunately we can't forget about other workloads, and we're
trying to stay away from runtime tunables in the scheduler.

If we can get performance to within a couple of tenths of a percent
of the zero balancing case, then that would be preferable I think.


Send instant messages to your online friends http://au.messenger.yahoo.com 
