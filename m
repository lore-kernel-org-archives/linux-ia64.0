From: Horms <horms@verge.net.au>
Date: Wed, 25 Jul 2007 07:10:21 +0000
Subject: Re: Regression in serial console on ia64 after 2.6.22
Message-Id: <20070725071019.GA18068@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070719074147.GA23879@verge.net.au>
In-Reply-To: <20070719074147.GA23879@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 19, 2007 at 07:08:30PM -0700, Yinghai Lu wrote:
> 
> how about modify boot_command_line and put machvec at the first entry.
> and use setup_machvec to call machvev_init.

This could work, but I think that it would most likely be cleaner
to just have machvec do its own parsing.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

