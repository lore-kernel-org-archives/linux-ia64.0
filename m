From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 28 Feb 2004 10:20:14 +0000
Subject: Re: Oops in pdflush
Message-Id: <16448.27486.350405.688607@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 28 Feb 2004 21:00:54 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Without DavidM's patch to add
  Keith> ia64_invoke_kernel_thread_helper, pdflush starts with 560
  Keith> bytes of stack and 744 bytes of rbs.  With
  Keith> ia64_invoke_kernel_thread_helper, that reduces to 554 bytes
  Keith> of stack and 272 bytes of rbs.  Backtrace with
  Keith> ia64_invoke_kernel_thread_helper.

Cool.  Thanks for reporting that and for providing the stack-dump (thanks
to Andreas, too, of course).

  Keith> We need both ia64_invoke_kernel_thread_helper and my patch to pdflush.
  Keith> Until all architectures have a kernel_thread helper, nested calls to
  Keith> kernel_thread will chew up stack.

Yes, I think so, too.  Andrew?

	--david
