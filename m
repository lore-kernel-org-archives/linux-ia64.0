From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 01 Nov 2002 12:58:54 +0000
Subject: Re: [Linux-ia64] mremap and "negative" addresses
Message-Id: <marc-linux-ia64-105590709805324@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805322@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805322@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 1 Nov 2002 12:21:28 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> hmm.. x86 handles this kind of thing by comparing against
  Matthew> (unsigned long)-125 instead.  any reason we can't do the
  Matthew> same?

Because on ia64 (like on Alpha, for example), there _is_ a clean
mechanism to return an error status and an error code at the syscall
level.

  Matthew> i also notice that sys_fcntl has no workaround:

That looks like a bug.

Both for mremap() and F_GETOWN, we should use the macro
force_successful_syscall_return() (not that this is an accepted macro
yet, but it makes the intention much clearer).

	--david

