From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 20 May 2003 06:31:35 +0000
Subject: Re: [Linux-ia64] offsets.h generation
Message-Id: <marc-linux-ia64-105590723705957@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 20 May 2003 11:26:31 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> OK, here's a patch that does it that way.  Because some of
  Peter> the needed header files in turn depend on a symbol from
  Peter> offsets.h, I had to create a dummy one `by hand' if it didn't
  Peter> previously exist.  A timestamp file,
  Peter> include/asm-ia64/.offsets.h.stamp, tracks when this was done
  Peter> so that 'make' after 'make clean' works; and 'make' after
  Peter> 'make' works.

Is processor.h the only cause of this recursive dependency?  As far as
I remember, we don't even need to include offsets.h in processor.h
anymore.  It used to be necessary for get_wchan(), but that's now an
out-of-line function.

	--david

