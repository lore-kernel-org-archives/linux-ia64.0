From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Thu, 20 Nov 2003 07:18:45 +0000
Subject: Re: Problems using psr.dd
Message-Id: <marc-linux-ia64-106931279713182@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 20, 2003 at 03:32:53PM +1100, Keith Owens wrote:
> 
> Forgot to mention, this is on a vanilla McKinley box, not a SN2.

I tried your code on an Itanium 1 (using 2.6.0-test9-bk without kdb,
s/kdb_printf/printk/).  I get exactly the same behaviour.

However if I take out the printk in do_trap29 (reducing the register
stack depth?) it seems to work okay.

Matt

