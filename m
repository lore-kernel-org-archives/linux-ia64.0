From: Steve Tynor <tynor@atlanta.twr.com>
Date: Wed, 25 Oct 2000 19:35:39 +0000
Subject: [Linux-ia64] setjmp/longjmp and/or *context() routines for IA64?
Message-Id: <marc-linux-ia64-105590678205629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A few weeks ago, David Mosberger responded to my request for a setjmp
implementation that I could use for doing user-mode context switches.  

He said that there were pending changes to setjmp that might help: 

|  (2) The current setjmp()/longjmp() implementation cannot be used for
|      stack switching purposes, because it does not preserve ar.rnat.
|      There was some discussion on what we should do about this and the
|      conclusion was to fix the routines so they do preserve ar.rnat.
|      The main argument for changing the routines was that the IA-64
|      SCRA requires ar.rnat to be part of the jmp_buf.

And further, 

|  (4) If the app absolutely must implement its own thread packages, use
|      the *context() routines defined by the Single UNIX Spec.  The
|      only trouble is that they haven't been implemented for Linux yet.
|      (Anyone volunteers?)

I've cvs up'd the latest glibc from http://sources.redhat.com/glibc/ and
all I see is version 2.1.95.  Are there relevant changes on the 2.2
branch?  If so, how do I go about getting access to the latest and
greatest?  Even if I can't use the glibc setjmp directly, I'm hoping I
can adapt it or something like it to what I need.  Seeing the diffs
David mentions in #2 above might help me better understand how the
voodoo works.

Thanks!
Steve

