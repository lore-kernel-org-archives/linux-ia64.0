From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 17 Dec 2002 03:50:53 +0000
Subject: [Linux-ia64] Re: ia64 cache flushing?
Message-Id: <marc-linux-ia64-105590709805596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805582@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805582@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 16 Dec 2002 19:42:51 -0800, Richard Henderson <rth@twiddle.net> said:

  Richard> On Mon, Dec 16, 2002 at 06:15:28PM -0800, David Mosberger
  Richard> wrote:
  >> For someone who cares about modules and ia64 performance: you
  >> might want to consider to use "brl" in the PLT stub instead of
  >> the standardized code sequence.

  Richard> You'll have to figure out how to find the plt stub though.
  Richard> It's not marked in any way.  The only thing you get a
  Richard> pointer to is the .IA_64.pltoff entry.

  Richard> For userland, the .plt stub has to use an indirect branch
  Richard> because the first invocation goes through the dynamic
  Richard> linker.  Then we update the .pltoff entry and so subsequent
  Richard> calls go direct to the target.

I assume you do early binding of the PLTs for kernel modules, right?
If so, patching the PLT code stub is trivial (even in user-land you
could do code patching, but that's obviously (a) not so trivial for
multi-threaded programs and (b) hurts sharing).

For user-level land, we should offer PLT-stub-inlining, but we
discussed this in private already...

	--david

