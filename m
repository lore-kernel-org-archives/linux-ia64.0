From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Jul 2003 21:13:12 +0000
Subject: Re: copy_thread preserves kernel stack
Message-Id: <marc-linux-ia64-105761241902152@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105719797219701@msgid-missing>
In-Reply-To: <marc-linux-ia64-105719797219701@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 03 Jul 2003 12:02:54 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> ia64 has a comment "Note: if we get called through
  Keith> kernel_thread() then the memory above "(highest addr)" is
  Keith> valid kernel stack memory that needs to be copied as well".
  Keith> i386 kernel threads work fine without the extra stack
  Keith> wastage, so there is no generic reason to save the parent
  Keith> backtrace.  Apart from unwind problems, I can see no reason
  Keith> for ia64 to preserve the parent's task in kernel threads.
  Keith> Any objections to me doing a patch that constructs an empty
  Keith> stack for ia64 kernel threads?

If the patch is clean, I wouldn't have a problem with it.  (Please
make sure that the call-chain of the child thread is properly
terminated, so the unwinder knows when to stop.)

(There used to be only few kernel threads, with little risk of kernel
 stack overflows, but nowadays (2.5.xx) the situation is quite
 different, so it probably makes sense to make this change).

	--david
