From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 18 Jan 2003 03:11:54 +0000
Subject: RE: [Linux-ia64] [Patch] Fix in process.c
Message-Id: <marc-linux-ia64-105590709805725@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Jan 2003 19:04:55 -0800, "Siddha, Suresh B" <suresh.b.siddha@intel.com> said:

  Suresh> hi David, Type of "ia64_ret_from_clone" is declared
  Suresh> differently here(char as against function) and we end up
  Suresh> linking object files with different types for the
  Suresh> symbol(which the linker will not like).

  Suresh> Current C-code is assuming gcc specific behaviour(gcc does
  Suresh> not fix the type for extern variables, leaves it to the
  Suresh> linker).

I understand that.  What I'm saying is that GCC does the sane thing.
There's got to be a way to get the address of a label without having
to materialize a function pointer.

	--david

