From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Tue, 12 Jun 2001 17:01:10 +0000
Subject: Re: [Linux-ia64] IO/TLB bounce buffer space
Message-Id: <marc-linux-ia64-105590693005719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005716@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005716@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Jun 2001, David wrote:

> The deeper question is of course: is this really a good idea?  From a
> latency perspective, such long queues may not make a lot of sense.
> Even from a throughput perspective the benefit of using a 253 entry
> queue is probably negligible compared to a shorter queue.  Reading
> aic7xxx.h, I get the impression that the author chose 253 as the max
> queue length because s/he could.  I don't see anything that suggests
> that this length is optimal in any sense.  It might be worth
> experimenting with.

Actually I found that if the driver "survives" the crash test (currently
with < 4GB RAM only) it eventually cuts the queue length for the disk
in question from 253 to 64 (max supported by the drive).

In any case, I assume some sort of compromise must be found. On a server
scale, a machine with 4 or even more Adaptec boards may well exist. Each
board supports 16 devices (32 if it's a 39160) and the default driver
setting is to use 253 buffers for each device.

Thus, worst case buffer usage would be 8kB * 253 * 16 * 4 = 126 MB only
for this driver! Of course it is highly unlikely that all these buffers
will be in use simultaneously. Even with only 16 SCBs per device, the
driver would still need 8MB of bounce buffers.

I guess it will be necessary to use both lower SCB numbers in the aic7xxx
driver and increase IO-TLB space.
All of this can already be done with kernel command line options, but
will be quite cumbersome to figure out (and tune right) for
administrators.

There will always be some danger of IO-TLB overflow, however, unless
a way is found to gracefully abort an operation if the IO-TLB space is
full (or unless all hardware vendors make their boards 64-bit capable).

Btw: will _hardware_ IO-TLB support be available some time soon?
(I figure that's what's being done on Alpha, right?)

I am currently trying to write a kernel module that allows monitoring of
IO-TLB usage.

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




