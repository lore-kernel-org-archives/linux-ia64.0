From: Chris Wedgwood <cw@f00f.org>
Date: Wed, 05 May 2004 16:18:14 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <20040505161814.GA7434@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 05, 2004 at 05:07:15PM +0100, Matthew Wilcox wrote:

> This is in 2.6.6-rc3.  I don't know when it was added.

Almost a year ago:

       http://linux.bkbits.net:8080/linux-2.5/cset%401.1046.264.19?nav=index.html|src/.|src/drivers|src/drivers/char|related/drivers/char/mem.c

(there are some relevant changes since then too obviously)


   --cw
