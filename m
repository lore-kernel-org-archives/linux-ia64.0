From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 06:36:46 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Dec 2000 17:31:07 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Wed, 13 Dec 2000 22:21:49 -0800, David Mosberger
  Keith> <davidm@hpl.hp.com> wrote:
  >> Sure, kdb should do it's job right, but kdb is certainly no
  >> reason to to hack the context switch code.  Not for something
  >> that 99.9% of the users never even know existed.

  Keith> One pointer in struct thread, one pointer in switch_stack, ~
  Keith> 15 instructions (2-3 extra bundles) to set the pointers
  Keith> during save_switch_stack, load_switch_stack and copy_thread.
  Keith> Is that too big a change?

It's not the amount of work the change that's involved, it's that the
change makes no sense whatsoever.  Surely you can find a better
solution?

	--david

