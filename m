From: Jes Sorensen <jes@linuxcare.com>
Date: Wed, 25 Oct 2000 19:43:43 +0000
Subject: Re: [Linux-ia64] setjmp/longjmp and/or *context() routines for IA64?
Message-Id: <marc-linux-ia64-105590678205630@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205629@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205629@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Steve" = Steve Tynor <tynor@atlanta.twr.com> writes:

Steve> | (4) If the app absolutely must implement its own thread
Steve> packages, use | the *context() routines defined by the Single
Steve> UNIX Spec.  The | only trouble is that they haven't been
Steve> implemented for Linux yet.  | (Anyone volunteers?)

Steve> I've cvs up'd the latest glibc from
Steve> http://sources.redhat.com/glibc/ and all I see is version
Steve> 2.1.95.  Are there relevant changes on the 2.2 branch?  If so,
Steve> how do I go about getting access to the latest and greatest?
Steve> Even if I can't use the glibc setjmp directly, I'm hoping I can
Steve> adapt it or something like it to what I need.  Seeing the diffs
Steve> David mentions in #2 above might help me better understand how
Steve> the voodoo works.

2.1.95 *is* the 2.2 branch, whats in sourceware.cygnus.com is the
latest.

Jes

