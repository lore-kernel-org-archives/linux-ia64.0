From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Thu, 24 Apr 2003 11:56:46 +0000
Subject: Re: [Linux-ia64] [PATCH] fix timer interrupts getting lost
Message-Id: <marc-linux-ia64-105590723705598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705596@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705596@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks Alex!

This patch fixed the problem I reported before.
And I could observe some "oops jumped a timer." messages
(with debug flag enabled).

>     This patch fixes the issue of some CPUs not showing timer interrupts
> going off.  Seems during the process of sync'ing the itc, we jumped over
> the next timer value.  This patch is against 2.5.67 + ia64.  I haven't
> seen the problem on 2.4, but a quick looks seems like it's potentially
> an issue there too.  Thanks,

>> Hi,
>> 
>> Thanks to Alex's fixes for PCI segment support, we could
>> boot 2.5.67 kernel on Tiger.  But a strange thing is happening.
>> Only cpu0 & 1 are getting timer interrupts and cpu 2 & 3 aren't.
>> This problem is reproducible and we see this phenomenon after every
>> boot.  It seems that these cpus stop receiving timer
>> interrupts after a very short while.
>> Has anyone seen this?

Thanks,
---
Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>


