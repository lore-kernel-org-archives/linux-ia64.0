From: Steve Woodruff <sjwoodr@yahoo.com>
Date: Wed, 23 Apr 2003 16:30:25 +0000
Subject: Re: [Linux-ia64] RT Timers problem
Message-Id: <marc-linux-ia64-105590723705592@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705588@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705588@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 2. In some cases, a call to timer_create() will
> block.
>    This one is harder to reproduce, but i've done it
>    multiple times and have something like this in 
>    my code:

Ok - i found the solution my self after some 
further research.  It appears that -lrt requires
-lpthread --even for non-threaded programs.  After
adding -pthread and explicitly listing -lpthread
before -lc in my link flags, all seems to be 
working as expected now.

tnx

/steve




==----------------------------------------------------------
 Steve Woodruff, N9OH @ 42.18N 88.34W, sjwoodr@yahoo.com

__________________________________________________
Do you Yahoo!?
The New Yahoo! Search - Faster. Easier. Bingo
http://search.yahoo.com

