From: James E Wilson <wilson@tuliptree.org>
Date: Mon, 19 Sep 2005 18:58:48 +0000
Subject: Re: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <1127156327.9310.11.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-09-19 at 10:46, David Mosberger-Tang wrote:
> This issue has been discussed before:
>   http://www.gelato.unsw.edu.au/archives/linux-ia64/0507/14541.html

It is wrong for gcc to complain about this, and it has been fixed for
the gcc-4.0.2 release, which should be out within a few weeks.  The
above URL contains a pointer to the GCC bug report which contains more
details.



