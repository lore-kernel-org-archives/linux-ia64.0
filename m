From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 20 May 2003 09:15:43 +0000
Subject: Re: [Linux-ia64] offsets.h generation
Message-Id: <marc-linux-ia64-105590723705958@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705941@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705941@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Tue, 20 May 2003 11:26:31 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> OK, here's a patch that does it that way.  Because some of the
Peter> needed header files in turn depend on a symbol from offsets.h,
Peter> I had to create a dummy one `by hand' if it didn't previously
Peter> exist.  A timestamp file, include/asm-ia64/.offsets.h.stamp,
Peter> tracks when this was done so that 'make' after 'make clean'
Peter> works; and 'make' after 'make' works.

David> Is processor.h the only cause of this recursive dependency?  As
David> far as I remember, we don't even need to include offsets.h in
David> processor.h anymore.  It used to be necessary for get_wchan(),
David> but that's now an out-of-line function.

I'll try deleting that one tomorrow when I'm in at work...  if we can
get rid of it, everything becomes *much* cleaner.

Peter C

