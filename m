From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Feb 2003 20:02:54 +0000
Subject: Re: [Linux-ia64] problem with ia64_fetch_and_add
Message-Id: <marc-linux-ia64-105590709805878@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805876@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805876@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Feb 2003 10:44:59 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> I'm having problem compiling code with macro function
  Ken> ia64_fetch_and_add.  What happens is if I use
  Ken> atomic_add_return() in one of the inline function, I'm getting
  Ken> unresolved symbol error at link time for
  Ken> __bad_increment_for_ia64_fetch_and_add().  But the input
  Ken> argument to ia64_fetch_and_add() is of constant 1 or -1.  I'm
  Ken> using gcc-3.2.2.

  Ken> Is this a toolchain problem?  Just for the sake of compile, the
  Ken> same code compiled without error with gcc-2.96, which kind of
  Ken> give me a fuzzy feeling that gcc-3.2 is not working for this
  Ken> case.  Has anyone seen this before?

That's normally an indication that you built with too low an
optimization level (you need to use at least -O1).

	--david

