From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Sep 2000 19:05:55 +0000
Subject: re: [Linux-ia64] setjmp/longjmp : flushing register stack
Message-Id: <marc-linux-ia64-105590678205522@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205495@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205495@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Sep 2000 10:04:15 -0700, David Mosberger <davidm@hpl.hp.com> said:

  David> Like I said before: the flushrs won't help at all.  The real
  David> issue is preserving ar.rnat (which is probably a problem you
  David> have not run into yet).

Steve pointed out that I hadn't said that on the linux-ia64 mailing
list.  I think he's right, so my apologies.

Here is a quick summary on the issue of setjmp/longjmp and their use
for context-switching:

 (1) as far as the current implementation is concerned, putting a
     flushrs in setjmp will make absolutely no difference because the
     state saved in the jmp_buf will be identical with or without the
     flushrs.

 (2) The current setjmp()/longjmp() implementation cannot be used for
     stack switching purposes, because it does not preserve ar.rnat.
     There was some discussion on what we should do about this and the
     conclusion was to fix the routines so they do preserve ar.rnat.
     The main argument for changing the routines was that the IA-64
     SCRA requires ar.rnat to be part of the jmp_buf.

 (3) the use of setjmp()/longjmp() for context switching is NOT
     recommended; linuxthreads/pthreads is preferable since that will
     allow to take advantage of multiple CPUs and is fully supported
     by libc.

 (4) If the app absolutely must implement its own thread packages, use
     the *context() routines defined by the Single UNIX Spec.  The
     only trouble is that they haven't been implemented for Linux yet.
     (Anyone volunteers?)

Hope this clarifies the situation.

	--david

