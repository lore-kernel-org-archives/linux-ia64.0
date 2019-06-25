From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Tue, 25 Jun 2019 06:46:57 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <7f701503-7bd3-28bf-d7e6-d52d3fd168ee@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/25/19 8:42 AM, Christoph Hellwig wrote:
>> Do you think we could test a kernel which just sets the flag unconditionally
>> to see whether this is the problem that causes the issues on these machines?
> 
> Might be worth a test.  Do you know what device failed?  Might be one
> with a dma mask < 32-bit?

I can reproduce the crash when trying to load the module for the USB controllers,
for example. Loading the kernel module for the SATA controllers provokes the
backtrace as well.

I have skimmed through the code a bit , but I'm not sure whether I understand
the code in kernel/dma/direct.c correctly, so my suggestion would be to just
set GFP_DMA32 in __dma_direct_alloc_pages() unconditionally for a test. Would
that be enough for a test?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
