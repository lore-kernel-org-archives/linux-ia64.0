From: Ryan Mallon <rmallon@gmail.com>
Date: Sun, 19 Jun 2011 23:02:17 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <4DFE7FF9.9070406@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu>
In-Reply-To: <20110617093032.GA19235@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 17/06/11 19:30, Ingo Molnar wrote:
> * Petr Tesarik<ptesarik@suse.cz>  wrote:
>
>> This patch series enhances /dev/mem, so that read and write is
>> possible at any address. The patchset includes actual
>> implementation for x86.
> This series lacks a description of why this is desired.
>
> My strong opinion is that it's not desired at all: /dev/mem never
> worked beyond 4G addresses so by today it has become largely obsolete
> and is on the way out really.
>
> I'm aware of these current /dev/mem uses:
>
>   - Xorg maps below 4G non-RAM addresses and the video BIOS
>
>   - It used to have some debugging role but these days kexec and kgdb
>     has largely taken over that role - partly due to the 4G limit.
>
>   - there's some really horrible out-of-tree drivers that do mmap()s
>     via /dev/mem, those should be fixed if they want to move beyond
>     4G: their char device should be mmap()able.

There are drivers where this makes sense. For example an FPGA device 
with a proprietary register layout on the memory bus can be done this 
way. The FPGA can simply be mapped in user-space via /dev/mem and 
handled there. If the device requires no access other than memory bus 
reads and writes then writing a custom char device driver just to get an 
mmap function seems a bit overkill.

~Ryan

