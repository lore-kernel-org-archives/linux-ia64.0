From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 20:13:29 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 08 Apr 2002 12:23:14 -0700, Ulrich Drepper <drepper@redhat.com> said:

  Uli> On Mon, 2002-04-08 at 12:00, David Mosberger wrote:
  >> So you're OK with glibc providing the syscall stubs for
  >> module*(), but not the header files required to use them?

  Uli> Yes.  There is no fundamental problems with this.

I guess I don't really see the harm in having glibc provide a header
for these system call, but as long as the syscall stubs are there,
it's probably not a huge issue in practice.

	--david

