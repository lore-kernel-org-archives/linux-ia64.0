From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 19:00:17 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905411@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 08 Apr 2002 10:51:06 -0700, Ulrich Drepper <drepper@redhat.com> said:

  Uli> On Mon, 2002-04-08 at 10:26, David Mosberger wrote:

  >> No, glibc needs to provide its own headers for this purpose.

  Uli> Wrong.  If you want this kind of functionality create your own
  Uli> module-dev package.  It is unfortunate that we have any such
  Uli> header in glibc butnot changeable.  I certainly will not add
  Uli> more.

So you're OK with glibc providing the syscall stubs for module*(), but
not the header files required to use them?

	--david

