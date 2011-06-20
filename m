From: Ryan Mallon <rmallon@gmail.com>
Date: Mon, 20 Jun 2011 00:46:08 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <4DFE9850.7030400@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<20110620004252.GE19693@parisc-linux.org>
In-Reply-To: <20110620004252.GE19693@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 20/06/11 10:42, Matthew Wilcox wrote:
> On Mon, Jun 20, 2011 at 09:02:17AM +1000, Ryan Mallon wrote:
>> There are drivers where this makes sense. For example an FPGA device
>> with a proprietary register layout on the memory bus can be done this
>> way. The FPGA can simply be mapped in user-space via /dev/mem and
>> handled there. If the device requires no access other than memory bus
>> reads and writes then writing a custom char device driver just to get an
>> mmap function seems a bit overkill.
> Calling a 30 line device driver "overkill" might in itself be overkill?
>
I mean overkill in the sense of having to write the driver at all. Why 
write a 30 line driver just to re-implement some functionality of /dev/mem?

~Ryan

