From: Steve Woodruff <sjwoodr@yahoo.com>
Date: Wed, 23 Apr 2003 15:05:49 +0000
Subject: Re: [Linux-ia64] RT Timers problem
Message-Id: <marc-linux-ia64-105590723705590@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705588@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705588@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--- Matthew Wilcox <willy@debian.org> wrote:
> Aren't these used by libc for thread management
> purposes?  RH uses NPTL
> so it ses different methods.

Might be - i checked the libc6.1 docs and it
mentions that USR1 and USR2 were used for that
purpose, but then goes on to say that after 
kernel 2.1.60 that was no longer the case.  It
didn't mention, but perhaps its switched to
those first three RT sigs?

/steve



==----------------------------------------------------------
 Steve Woodruff, N9OH @ 42.18N 88.34W, sjwoodr@yahoo.com

__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com

