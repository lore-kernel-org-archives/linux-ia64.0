From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 29 Jul 2005 09:01:22 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <20050729090122.GB8699@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <42E9ED47.1030003@yahoo.com.au> <20050729085340.GA8699@elte.hu> <42E9EFDD.4020703@yahoo.com.au>
In-Reply-To: <42E9EFDD.4020703@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> >>processes    1               2               3              4
> >>
> >>2.6.13-rc4:  187, 183, 179   260, 259, 256   340, 320, 349  504, 496, 500
> >>no wake-bal: 180, 180, 177   254, 254, 253   268, 270, 348  345, 290, 500
> >>
> >>Numbers are MB/s, higher is better.
> >
> >
> >what type of network was used - localhost or a real one?
> >
> 
> Localhost. Yeah it isn't a real world test, but it does show the 
> erratic behaviour without wake affine.

yeah - fine enough. (It's not representative for IO workloads, but it's 
representative for local IPC workloads, just wanted to know precisely 
which workload it is.)

	Ingo
