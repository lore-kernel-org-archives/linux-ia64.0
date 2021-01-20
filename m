From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 20 Jan 2021 16:09:51 +0000
Subject: Re: [PATCH] ia64: add support for TIF_NOTIFY_SIGNAL
Message-Id: <17cd57b5-c728-193f-3776-d6fcceeedcbb@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
In-Reply-To: <d3a2aa1e-0fae-1d3f-519f-d32adc608c38@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/20/21 5:08 PM, Jens Axboe wrote:
>> This change broke the hpsa driver on my RX-2600 ia64 workstation in the sense that the
>> driver no longer loads and hence hard disks are no longer recognized.
> 
> What does "no longer loads" mean? Does it hang?

It does not load at all. The driver no longer shows up in the kernel message buffer
and therefore no disks are found.

>> Any idea what could be wrong?
> 
> Can you try current -git? There's a task_work related fix in there which is
> related to this series, maybe that's it...

I can. However, I already tested 5.11-rc4 before I sent the mail.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
