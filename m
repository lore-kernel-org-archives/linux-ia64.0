From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 06:53:39 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005311@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 20 Mar 2001 16:24:23 -0800, Jim Wilson <wilson@cygnus.com> said:

  Jim> I do not know what the kernel uses the unwind info for.  This
  Jim> question has been asked on this list by others recently and has
  Jim> not been answered.

The kernel uses unwind info for a number of things:

	- to generate backtraces to aid debugging; kdb uses this
	  but we also use it in a number of other places where
	  we want to print a backtrace

	- to obtain the register values of "preserved" registers from
	  "earlier" call frames

	- to reconstruct the user-level values of the "preserved"
	  registers (e.g., this is used for ptrace() and when
	  creating a core dump)

Please let me know if this doesn't answer your question.

	--david

