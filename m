From: Dan Pop <Dan.Pop@cern.ch>
Date: Thu, 07 Dec 2000 04:32:41 +0000
Subject: Re: [Linux-ia64] Re: Fault 26?
Message-Id: <marc-linux-ia64-105590678205805@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205793@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205793@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 6 Dec 2000, Bill Nottingham wrote:

> David Mosberger (davidm@hpl.hp.com) said: 
> >   Bill> What is fault type 26?  I'm getting a few of these recently.
> > 
> > It's the "NaT consumption fault".  Either buggy code is trying to eat
> > a NaT value or something else goes wrong and a NaT value is created
> > when it shouldn't be.
> 
> It's happening in strcpy(), of all places, with two seemingly valid
> arguments.

Here's a patch that should fix it.  The bug was in a recovery code
that was highly unlikely to be ever executed, hence it passed
unnoticed for so long :-)

2000-12-07  Dan Pop  <Dan.Pop@cern.ch>

        * sysdeps/ia64/strcpy.S: fix a bug in a recovery code sequence


--- strcpy.S.old	Thu Dec  7 05:10:17 2000
+++ strcpy.S	Thu Dec  7 05:11:20 2000
@@ -120,7 +120,7 @@
 	br.ret.sptk.many b0
 .recovery2:
 	add	tmp = -8, asrc ;;
-	ld8	r[MEMLAT] = [tmp]
+	ld8	r[0] = [tmp]
 	br.cond.sptk .back2
 .recovery3:
 	add	tmp = -(MEMLAT + 1) * 8, src ;;


Thanks to David Mosberger for investigating the problem.

Dan


