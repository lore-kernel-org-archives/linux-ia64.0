From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 16 Jul 2006 02:54:51 +0000
Subject: Re: Problem with Guile on ia64 (possibly "getcontext" related)
Message-Id: <16307.1153018491@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <87ac7ajylc.fsf@raven.defaultvalue.org>
In-Reply-To: <87ac7ajylc.fsf@raven.defaultvalue.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rob Browning (on Sat, 15 Jul 2006 15:24:31 -0700) wrote:
>
>Guile 1.6.8 is crashing on ia64 with an illegal instruction whenever
>it tries to execute call-with-current-continuation.  For those who
>don't know, call-with-current-continuation captures the current state
>of the computation; it's a language feature somewhat similar to
>setjmp.
>
>The crash seems to be right around an asm "getcontext" call, and after
>looking around, I found these two links:
>
>  http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/144939
>  http://lists.freebsd.org/pipermail/freebsd-sparc64/2006-January/003739.html
>
>They appear claim that adding a dummy (non-executed) setjmp just after
>the getcontext call will fix the problem because gcc recognizes
>setjmp, but not getcontext, and makes appropriate arrangements.
>
>So I tried adding a dummy setjmp just after the getcontext call, and
>that does fix the problem.
>
>However, even though this worked, I'd still prefer to have a better
>idea that this is the right fix before adopting it.  Is that likely?
>>
>The relevant function is scm_make_continuation which you can find
>here:
>
>  http://cvs.savannah.gnu.org/viewcvs/guile/guile-core/libguile/continuations.c?rev=1.38.2.7&root=guile&only_with_tag=branch_release-1-6&view=markup

Wild guess, based on no data.  Add '__attribute__ ((returns_twice))' to
the definition of ia64_getcontext.  That should remove the need to use
setjmp.

