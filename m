From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 31 Aug 2000 18:56:44 +0000
Subject: Re: [Linux-ia64] SMP TLB flushes
Message-Id: <marc-linux-ia64-105590678205430@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205428@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205428@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 31 Aug 2000 19:57:11 +0200, Manfred Spraul <manfred@colorfullife.com> said:

  Manfred> * could you add a big warning to start_lazy_tlb
  Manfred> [kernel/exit.c] that the function is unsafe?  Both ppc and
  Manfred> ia64 scan the task list and assume that they can find each
  Manfred> mm_struct. If someone actually uses start_lazy_tlb, then
  Manfred> that would be incorrect.

Why are you asking on the IA-64 list for this change?  It's in a
platform-independent file so it's up to Linus to decide what to do
with that function.  It's presently unused and if it's not safe, why
not get rid of it?

	--david

