From: Greg KH <gregkh@suse.de>
Date: Mon, 20 Mar 2006 19:54:15 +0000
Subject: Re: [PATCH 2.6.16-rc6-mm1] fix ia64 MSI build problems
Message-Id: <20060320195415.GA17263@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060320193638.GH31238@sgi.com>
In-Reply-To: <20060320193638.GH31238@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@osdl.org, j-nomura@ce.jp.nec.com

On Mon, Mar 20, 2006 at 01:36:38PM -0600, Mark Maule wrote:
> Fix MSI-related build problems on ia64.
> 
> Move arch/ia64/sn/pci/msi.c to drivers/pci/msi-altix.c
> Move struct msi_ops in drivers/pci/msi.h to the top of the file so asm/msi.h
>     can make use of the declaration.
> Clean up msi platform defintions in machvec.h (thanks to j-nomura@ce.jp.nec.com
>     for the patch to do that).
> 
> Signed-off-by: Mark Maule <maule@sgi.com>

Does this replace any of your pre-existing msi patches in my tree (and
in -mm)?  Shouldn't you just merge a few of them together now so that if
someone were to apply stuff in order, the build is not broken for any
step along the patch trail?

And also, the Makefile should be changed as Matthew pointed out.

So, care to redo this?

thanks,

greg k-h
