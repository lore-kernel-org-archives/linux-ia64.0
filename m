From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 13 Aug 2003 00:07:51 +0000
Subject: Re: milstone reached: ia64 linux builds out of Linus' tree
Message-Id: <marc-linux-ia64-106073337821122@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106001867501939@msgid-missing>
In-Reply-To: <marc-linux-ia64-106001867501939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 04, 2003 at 04:35:32PM -0700, David Mosberger wrote:
>   David> Now that Linus' tree works for ia64, the next question is how
>   David> we can keep it that way.  I think it would be useful to have
>   David> someone setup a cron job which does daily builds/automated
>   David> tests off of Linus tree. 
> 
>   Peter> We'd probably do daily automated builds to check that the kernel
>   Peter> still compiles cleanly for HPSIM, DIG, and ZX1, but test only weekly.

It has been running OK for a few days now, so please feel free to
check out

http://www.gelato.unsw.edu.au/kerncomp

for the status of daily IA64 builds.  We will attempt to keep track of
what is happening and fix anything that needs fixing or point to where
it has been fixed.

We're still working on automated testing (i.e. booting on the
simulator, maybe real hardware).

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
