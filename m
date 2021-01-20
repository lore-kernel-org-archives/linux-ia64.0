From: Jens Axboe <axboe@kernel.dk>
Date: Wed, 20 Jan 2021 16:12:02 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <04b3bda1-3d27-ff70-e8a1-4dae62e2033f@kernel.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/20/21 9:09 AM, John Paul Adrian Glaubitz wrote:
> On 1/20/21 5:08 PM, Jens Axboe wrote:
>>> This change broke the hpsa driver on my RX-2600 ia64 workstation in the sense that the
>>> driver no longer loads and hence hard disks are no longer recognized.
>>
>> What does "no longer loads" mean? Does it hang?
> 
> It does not load at all. The driver no longer shows up in the kernel message buffer
> and therefore no disks are found.

Really should be no relation there at all. Is it built-in or modular?

>>> Any idea what could be wrong?
>>
>> Can you try current -git? There's a task_work related fix in there which is
>> related to this series, maybe that's it...
> 
> I can. However, I already tested 5.11-rc4 before I sent the mail.

-rc4 doesn't have the fix, it wasn't merged until yesterday. I doubt
that it's related to this though...

-- 
Jens Axboe
