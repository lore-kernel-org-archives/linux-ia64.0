From: Ryan Mallon <rmallon@gmail.com>
Date: Mon, 20 Jun 2011 08:03:12 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <4DFEFEC0.3040703@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu> <4DFE7FF9.9070406@gmail.com>
	<20110620073122.GA24716@elte.hu>
In-Reply-To: <20110620073122.GA24716@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 20/06/11 17:31, Ingo Molnar wrote:
> * Ryan Mallon <rmallon@gmail.com> wrote:
>
>> On 17/06/11 19:30, Ingo Molnar wrote:
>>> * Petr Tesarik<ptesarik@suse.cz>  wrote:
>>>
>>>> This patch series enhances /dev/mem, so that read and write is
>>>> possible at any address. The patchset includes actual
>>>> implementation for x86.
>>> This series lacks a description of why this is desired.
>>>
>>> My strong opinion is that it's not desired at all: /dev/mem never
>>> worked beyond 4G addresses so by today it has become largely obsolete
>>> and is on the way out really.
>>>
>>> I'm aware of these current /dev/mem uses:
>>>
>>>  - Xorg maps below 4G non-RAM addresses and the video BIOS
>>>
>>>  - It used to have some debugging role but these days kexec and kgdb
>>>    has largely taken over that role - partly due to the 4G limit.
>>>
>>>  - there's some really horrible out-of-tree drivers that do mmap()s
>>>    via /dev/mem, those should be fixed if they want to move beyond
>>>    4G: their char device should be mmap()able.
>> There are drivers where this makes sense. For example an FPGA 
>> device with a proprietary register layout on the memory bus can be 
>> done this way. [...]
> So you want us to help vendors screw users with insane, proprietary, 
> user-space drivers with sekrit binary blobs?
>
> Wow.
It's not about that. I mean proprietary in the sense that the register
layout is not based on some open spec and is customised to some
particular usage, not that it is evil, anti-GPL and "sekrit". I have
worked on embedded products which have custom FPGAs for _very_ dedicated
usage. The FPGA firmware is company IP and therefore not open (which is
nothing to do with Linux). The types of products I'm talking about are
often very niche market and dedicate use and therefore not a case of
vendors screwing over the general public. Writing the drivers in
user-space makes development easier; it's not an attempt to hide code
from the public. There is nothing to stop a /dev/mem userspace driver
from being open, just as there is nothing to stop a kernel driver for a
closed platform under Linux being "closed".

~Ryan

