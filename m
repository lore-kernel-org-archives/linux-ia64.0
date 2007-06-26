From: Robert Nagy <robert.nagy@gmail.com>
Date: Tue, 26 Jun 2007 10:13:27 +0000
Subject: Re: intercept trap when running a 32bit binary
Message-Id: <20070626101327.GA15067@bsd.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've set the pagesize to 4096 in the kernel but that did not
solve the problem.

On (25/06/07 16:45), Luck, Tony wrote:
> Nothing useful there for me either ... though since the crash
> looks like it is happening in some constructors, it is possible
> that your program has some mistaken hard-coded assumptions that
> the pagesize is 4K.  But that is just a really wild guess.
> 
> -Tony
