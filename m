From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Thu, 17 May 2001 17:40:17 +0000
Subject: Re: [Linux-ia64] Software IO-TLB Kernel panic
Message-Id: <marc-linux-ia64-105590693005606@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005601@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005601@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>   Martin> The kernel panic occurs in map_single
>   Martin> (arch/ia64/lib/swiotlb.c:171).
>
> Sounds like the driver is trying to map buffers that are bigger than
> (1 << IO_TLB_SHIFT) (currently 2KB).

I looked at the code and thought that bigger buffers than 2kB can (in
principle) be created by joining subsequent buffers.
Of course, it could happen that no such contiguous space is available.
Am I wrong ?

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




