From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 08 Feb 2002 06:40:13 +0000
Subject: Re: [Linux-ia64] Re: O(1) MQ scheduler J9 patch for IA64
Message-Id: <marc-linux-ia64-105590698806027@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 7 Feb 2002 22:37:41 -0800, William Lee Irwin III <wli@holomorphy.com> said:

  Bill> On Thu, Feb 07, 2002 at 10:11:28PM -0800, David Mosberger
  Bill> wrote:
  >> A somewhat cheesy solution might be to have a per-CPU flag that
  >> indicates whether a CPU should flush its TLB before switching to
  >> the next task.  We could check for this in activate_mm().  Do you
  >> want to try this?

  Bill> Would this be a good thing to put in the mmu_context? It seems
  Bill> like that could isolate it within arch-specific code.

It's arch-specific either way.  The flag needs to be per CPU, not per task.

	--david

