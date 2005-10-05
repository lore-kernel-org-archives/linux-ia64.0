From: Jeff Licquia <licquia@progeny.com>
Date: Wed, 05 Oct 2005 23:09:46 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <1128553786.4623.83.camel@laptop1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-10-05 at 15:33 -0700, Luck, Tony wrote:
> Running with a kernel configured for 4K pagesize, this
> test passes (prints "the write appeared to succeed").
> 
> I expect this difference in behavior can be traced to when
> Linus improved pipe performance by allowing a list of many
> pages to implement the pipe buffer.  See http://tinyurl.com/7jfen
> 
> The date on this is Jan 6th, 2005 ... which puts it between
> 2.6.10 and 2.6.11-rc1

This implies that PIPE_BUF should be equal to the kernel's configured
page size on ia64.  I modified my test to report on PIPE_BUF's returned
value, and it is 4096 on all my tested architectures, including ia64 on
2.6.8 and 2.6.12.

(Also, the page size on my 2.6.8 ia64 kernel is 16K, same as my 2.6.12
kernel.)

It strikes me that, if this is correct, forcing 4K page size isn't the
right fix.  Do you have any ideas on that front?

