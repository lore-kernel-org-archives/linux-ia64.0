From: Andrew Morton <akpm@osdl.org>
Date: Wed, 27 Sep 2006 23:31:00 +0000
Subject: Re: 2.6.18 perfmon new code base + libpfm + pfmon
Message-Id: <20060927163100.e83a1f79.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060926143420.GF14550@frankl.hpl.hp.com>
	<20060926220951.39bd344f.akpm@osdl.org>
	<20060927224832.GA17883@frankl.hpl.hp.com>
In-Reply-To: <20060927224832.GA17883@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 27 Sep 2006 15:48:32 -0700
Stephane Eranian <eranian@hpl.hp.com> wrote:

> Andrew,
> 
> Here is the summary of the various point raised by your review and the current
> status. I am hoping to close all points by next release.
> 
> ...
> 
> [akpm]: use fget_light() in some place instead of fget()
> 	- not sure understand when to use one versus the other
>

They are always interchangeable.  fget_light() is simply an optimised,
messier-to-use version.

>
> ..
>
> [akpm]: carta_random32() should be in another header file
> 	- yes, I know. Should I create a specific header file? I don't think random.h
> 	  is meant for this.

I suppose so.  Or just stick the declaration into kernel.h.

I had a patch go past the other day which had a hand-rolled
fast-but-not-very-good pseudo random number generator in it.  I couldn't
remember where I'd seen one, and now I can't remember what patch it was
that needed it.  Sigh.

Anyway, a standalone patch which adds that function into lib/whatever.c
would be nice.

