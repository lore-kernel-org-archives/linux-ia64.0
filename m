From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 13 May 2003 07:18:32 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Salut Bruno,

On Tue, May 13, 2003 at 09:02:48AM +0200, Bruno Vidal wrote:
> I've already wrote a dump modules driver for linux-parisc.
> This module goal is to create a memory image on a swap area, and
> at reboot time to save it to disk with all kernel modules, in
> order to analyze it after by "support" people with tools like
> gdb/p4. The problem while dumping is that the dump modules
> cannot trust anymore the system, so dumping means: no interruption,
> no disk driver, no buffer, nothing. The solution is to use low level
> call. For parisc I use the IODC calls, for ia64 I think I'll
> use the EFI calls. My questions:
> -do you think it is a "good" and realistic solution.

I don't think it is because, I think you are missing an important
feature of EFI. The last step taken by elilo before jumping to the
first instruction of the kernel is to switch EFI into runtime mode
(compared to boot time mode intially). There is no way back. In
runtime mode, almost none of the EFI services you get at boot time
remain available. The code/data memory areas are reclaimed by the kernel. 
The parts of EFI that remain are tagged 'runtime' and mostly consist
of a subset of what you have at bootime: reset, gettimeofday, runtime
drivers (fpswa). None of the I/O support is left.


the kernel, EFI is 
> -because I think "yes", does exist somewhere an example of
> reading/writing with EFI call on disk using BLOCK IO. I've already
> looked in elilo, but it seems that it use FS access.

Not quite. If you looked at the ext2 emulation, it uses the BlockIO 
protocol.

-- 
-Stephane

