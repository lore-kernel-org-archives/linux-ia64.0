From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 31 Oct 2002 17:46:31 +0000
Subject: Re: [Linux-ia64] Header dependencies
Message-Id: <marc-linux-ia64-105590709805317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805316@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805316@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 31 Oct 2002 16:48:35 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> I think the basic problem is that thread_info and
  Matthew> task_struct are the wrong way round on the stack.  If we
  Matthew> put thread_info first then we don't need IA64_TASK_SIZE in
  Matthew> current_thread_info's definition.  What would people think
  Matthew> to this rearrangement?  I guess some asm code might need to
  Matthew> be changed, and I'm still scared of ia64 assembler ;-)

I think I tried that back when the thread_info ugliness was
introduced.  Making it work would require more changes to the platform
independent portions of the kernel (which may well be the right thing
to do).  But my memory may be wrong---if you can make it work, I'd be
OK with the change.

	--david

