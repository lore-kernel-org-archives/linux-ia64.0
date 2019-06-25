From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 08:38:17 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <c5412a03-e3ce-eecd-737f-119c7d955ed3@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/25/19 10:18, Christoph Hellwig wrote:
> On Tue, Jun 25, 2019 at 10:16:22AM +0200, Frank Scheiner wrote:
>> Looks like this patch is not enough or not related, a kernel v5.1.15
>> with that patch applied yields the following:
>
> Can you use gdb to disassemle the faulting addresss?
>
> Something like:
>
> gdb vmlinux
>
> The in gdb:
>
> l *(__alloc_pages_nodemask+0x281)

Will do. I didn't have gdb installed so it might take some time to
emerge it. Will report back with the requested information then.
