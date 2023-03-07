From: patchwork-bot+linux-riscv@kernel.org
Date: Tue, 07 Mar 2023 00:48:58 +0000
Subject: Re: [PATCH 01/10] alpha: fix livelock in uaccess
Message-Id: <167815013840.19612.4686188583677266510.git-patchwork-notify@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9l0EDRr9DpNb5Pb@ZenIV>
In-Reply-To: <Y9l0EDRr9DpNb5Pb@ZenIV>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-riscv@lists.infradead.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, monstr@monstr.eu, dinguyen@kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, sparclinux@vger.kernel.org, torvalds@linux-foundation.org

Hello:

This series was applied to riscv/linux.git (fixes)
by Al Viro <viro@zeniv.linux.org.uk>:

On Tue, 31 Jan 2023 20:03:28 +0000 you wrote:
> alpha equivalent of 26178ec11ef3 "x86: mm: consolidate VM_FAULT_RETRY handling"
> If e.g. get_user() triggers a page fault and a fatal signal is caught, we might
> end up with handle_mm_fault() returning VM_FAULT_RETRY and not doing anything
> to page tables.  In such case we must *not* return to the faulting insn -
> that would repeat the entire thing without making any progress; what we need
> instead is to treat that as failed (user) memory access.
> 
> [...]

Here is the summary with links:
  - [01/10] alpha: fix livelock in uaccess
    (no matching commit)
  - [02/10] hexagon: fix livelock in uaccess
    (no matching commit)
  - [03/10] ia64: fix livelock in uaccess
    (no matching commit)
  - [04/10] m68k: fix livelock in uaccess
    (no matching commit)
  - [05/10] microblaze: fix livelock in uaccess
    (no matching commit)
  - [06/10] nios2: fix livelock in uaccess
    (no matching commit)
  - [07/10] openrisc: fix livelock in uaccess
    (no matching commit)
  - [08/10] parisc: fix livelock in uaccess
    (no matching commit)
  - [09/10] riscv: fix livelock in uaccess
    https://git.kernel.org/riscv/c/d835eb3a57de
  - [10/10] sparc: fix livelock in uaccess
    (no matching commit)

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

