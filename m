From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 13 Apr 2002 02:17:05 +0000
Subject: Re: [Linux-ia64] Missing EXPORT_SYMBOL memset
Message-Id: <marc-linux-ia64-105590701905449@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 12 Apr 2002 19:10:24 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sat, 13 Apr 2002 11:55:13 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> I know about the "gcc decides to insert memset after cpp
>  Keith> phase" problem.  When it occurred in the past (it used to
>  Keith> happen with gcc 2.7 in 2.[02] kernels) the response was
>  Keith> always to change the source code to prevent gcc making this
>  Keith> wrong decision.
>
>I don't see much wrong with gcc generating calls to memset().
>What problem are you worried about?

Because those calls are generated after cpp has run so they do not use
#define memset.  We end up with two classes of memset, most using the
macro but a few using the function.  When this problem occurred in the
context of gcc 2.7 and 2.[02] kernels, the response was always to
change the source code to prevent gcc generating code that we did not
want.  If that decision is going to change, it needs to be run past l-k
first.


