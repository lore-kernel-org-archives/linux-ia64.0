From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Dec 2000 07:40:47 +0000
Subject: Re: [Linux-ia64] switch_stack position
Message-Id: <marc-linux-ia64-105590678205841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205821@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205821@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Dec 2000 18:30:56 +1100, Keith Owens <kaos@ocs.com.au> said:

  >>  Have you actually tried doing a "btp" on an IA-64 stack that
  >> isn't valid?  I think you'll find that unw_unwind() returns -1
  >> long before unwinding to user-space.  That's probably as good an
  >> indication as any that the stack is still active.

  Keith> But I don't want unwind to return -1 or produce garbage,
  Keith> which is what it occurs now when the stack state does not
  Keith> match the assumptions.

What's so hard about writing a function that returns 1 if it was able
to unwind the kernel stack completely and 0 otherwise?

	--david

