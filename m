From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 29 Jul 2005 08:59:09 +0000
Subject: Re: Delete scheduler SD_WAKE_AFFINE and SD_WAKE_BALANCE flags
Message-Id: <42E9EFDD.4020703@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <42E9ED47.1030003@yahoo.com.au> <20050729085340.GA8699@elte.hu>
In-Reply-To: <20050729085340.GA8699@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>processes    1               2               3              4
>>
>>2.6.13-rc4:  187, 183, 179   260, 259, 256   340, 320, 349  504, 496, 500
>>no wake-bal: 180, 180, 177   254, 254, 253   268, 270, 348  345, 290, 500
>>
>>Numbers are MB/s, higher is better.
> 
> 
> what type of network was used - localhost or a real one?
> 

Localhost. Yeah it isn't a real world test, but it does show the
erratic behaviour without wake affine.

I don't have a setup with multiple fast network adapters otherwise
I would have run a similar test using a real network.

Send instant messages to your online friends http://au.messenger.yahoo.com 
