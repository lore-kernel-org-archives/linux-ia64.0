From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 13 Aug 2001 17:02:47 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Noah" = Noah Romer <nromer@lsil.com> writes:

Noah> I'm in the process of adding support for the ia64 architecture
Noah> to the message/fusion/mptlan.c driver (it's previously only been
Noah> tested with i386 and sparc64 systems) and have come across a
Noah> couple of issues:

Is this a kernel driver or a userland application? If it's the latter
then you are not allowed to rely on kernel definitions etc.

Noah> 2) atomic_sub looks to require that I cast a u8 to (int) when I
Noah> pass it in as a parameter. Not a major issue, I just found it
Noah> odd.

Noah> I'm most likely missing something (didn't see anything about
Noah> either of the above when I looked through the list archive), but
Noah> I was wondering if I could get a pointer or two from those with
Noah> more knowledge of ia64/linux issues.

You are talking about the subtracted argument I take it? It's int on
most architectures, including Linux/i386:

static __inline__ void atomic_sub(int i, atomic_t *v)
{
	__asm__ __volatile__(
		LOCK "subl %1,%0"
		:"=m" (v->counter)
		:"ir" (i), "m" (v->counter));
}

Jes

