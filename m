From: Einar Saltnes <eisa@scali.no>
Date: Wed, 18 Oct 2000 09:53:12 +0000
Subject: Re: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205590@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205567@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205567@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi again,

Takayoshi Kouchi wrote:
> 
> Hi all,
> 
> 
> We have seen the same problem as yours.  We have upgraded our BigSur
> with an upgrade kit from Intel.  It had originally only one processor,
> but we replaced it with two B0 processors.
> While running 2.4.0-test9 kernel, we noticed that timer interrupt of CPU0
> would stop at some time after boot.

I can see that cpu0 is the one stopping after some time looking at
/proc/stat. Very interesting!

And to David M.:
I am positive that I have remembered to do "make clean" and "make dep"
before making new kernel. I have observed the same behaviour on three
different kernels, built using only minor differences in the
configuration.

Thank you!

Einar Saltnes
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

