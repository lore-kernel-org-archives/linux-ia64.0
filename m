From: Keith Owens <kaos@sgi.com>
Date: Wed, 28 Jan 2004 21:50:57 +0000
Subject: Re: salinfo-0.4 patch
Message-Id: <10165.1075326657@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1075324928.25461.273.camel@xenophanes>
In-Reply-To: <1075324928.25461.273.camel@xenophanes>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 28 Jan 2004 13:22:08 -0800, 
Ben Woodard <woodard@redhat.com> wrote:
>Here is a tiny patch for salinfo-0.4. There is a problem with when it
>deals with multiple errors. The decoded error messages fill up with
>progressively more white space. 

That should not occur, the ++indent/--indent lines should be matched.
Instead of forcing indent back to 0, please find the missing line and
fix it.  Correct code is better than an arbitrary reset.

If you have a sample of nested indent that will help track down the
bug, send it to kaos@sgi.com.

>While poking around in the iprint function, I also found an error
>message that looks like it is better suited for stderr rather than
>stdout so I retargetted it.

No.  I deliberately used stdout so the error message would appear at
the end of the truncated file on disk, to tell the viewer that this
particular file was incomplete.  stderr is useless when salinfo_decode
is run from init.d.

