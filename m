From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 13 Mar 2000 18:52:17 +0000
Subject: Re: [Linux-ia64] Q: stack coherency
Message-Id: <marc-linux-ia64-105590678204982@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204981@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204981@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 11 Mar 2000 10:02:06 +0100, Manfred Spraul <manfreds@colorfullife.com> said:

  Manfred> Can I access a structure that's stored on the stack of one
  Manfred> CPU from another CPU?

IA-64 is no different in this respect from other architectures.  If
you have an SMP/NUMA/whatever system where the CPUs share the
address-space, you will be able to access the stack of another thread
(assuming the thread's stack is mapped in the address space).  Of
course, you also need to have proper synchronization to ensure the
stack is still live when the second CPU is trying to access it.

I'm not 100% sure what you're asking though, because the "subject"
line of your mail asks about stack coherency.  Coherency is an
orthogonal issue to accessibility.  IA-64 uses a weakly ordered memory
model to achieve high performance.  It's probably best to read the
IA-64 architecture manual for the details (see Section 4.4 at
http://devresource.hp.com/devresource/Docs/Refs/IA64ISA/), but loosely
speaking, memory accesses that happen between a spin-lock/-unlock
pair, will be ordered with respect to accesses by other CPUs.

	--david


