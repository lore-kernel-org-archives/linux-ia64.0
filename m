From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 21 Oct 2003 20:56:49 +0000
Subject: Re: [RFC] Endianness and signals
Message-Id: <marc-linux-ia64-106677006020854@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106669369711349@msgid-missing>
In-Reply-To: <marc-linux-ia64-106669369711349@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 21 Oct 2003 13:37:00 -0700, Cary Coutant <cary@cup.hp.com> said:

  Cary> I think the right thing to do is set the PSR.be bit on
  Cary> delivery of a signal to match (elf_header.e_flags &
  Cary> EF_IA_64_BE).

The kernel does not support the loading of big-endian executables, so
this would be equivalent to always clearing PSR.be on a signal.

  Cary> I'm not sure I buy the argument that you shouldn't change the
  Cary> behavior now because it's been that way for a long time. What
  Cary> you have now is unpredictable, so the only ways a signal
  Cary> handler could work in an application that switches the PSR.be
  Cary> bit on a regular basis are: (1) it just gets lucky, and never
  Cary> gets an interrupt while in the wrong state, (2) the
  Cary> application blocks signals while in the opposite state, or (3)
  Cary> the signal handler forces the PSR.be to what it wants. In any
  Cary> of these cases, the proposed behavior will work.

The fourth case is that the application has signal handlers that
expect to get called in the "opposite" byte-order and those are the
ones that would break if we changed the current behavior.

	--david
