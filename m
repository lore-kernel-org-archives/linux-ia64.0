From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Jan 2001 16:29:27 +0000
Subject: Re: [Linux-ia64] PATCH:  Building on ia32
Message-Id: <marc-linux-ia64-105590693005076@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005061@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 18 Jan 2001 10:47:07 -0500 (EST), William Taber <wtaber@rational.com> said:

  William> Actually, I think the best solution is to move
  William> is_exec_access() and is_write_access() out of
  William> asm-ia64/pgtable.h, and into some machine independent
  William> header (perhaps mm.h ?), redefining the magic numbers 2 and
  William> 4 to be VM_WRITE and VM_EXEC respectively.  This still
  William> leaves the question of who is responsible for changing all
  William> of the platform specific callers of handle_mm_fault to
  William> reflect the new semantics?

The sole reason for the existence of those macros is so they can be
defined in a platform-specific way.  No other platform is currently
using lazy-execute bits and on those platforms, there is no need to
check the executable bit in the page fault handler.  However, I don't
think is_exec_access() is the final answer either---that's why I don't
bother updating the other ports: it's still very much works in
progress.

	--david

