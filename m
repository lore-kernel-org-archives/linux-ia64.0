From: dann frazier <dannf@hp.com>
Date: Wed, 29 Sep 2004 19:13:05 +0000
Subject: Re: kernel troubles on rx2600 while running sbuild
Message-Id: <20040929191305.GC32229@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040926183333.1592f4cd@Tatooine.r3z0>
In-Reply-To: <20040926183333.1592f4cd@Tatooine.r3z0>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 29, 2004 at 09:47:42AM +0200, Thibaut VARENE wrote:
> On Wed, 29 Sep 2004 09:17:20 +0200
> Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> 
> > Hi,
> > 
> > Another report, that happened tonight while the box was idling (after
> > having built quite a lot of packages - about 1000 - without problems),
> > and which was apparently triggered by a cron task (at 5 AM). There
> > again (see at the end) there's a kernel NULL pointer dereference. Full
> > dump attached.
> > 
> > rx2600 1-way 2GB RAM
> > Debian sarge, kernel-image-2.4.27-mckinley

> Unable to handle kernel paging request at virtual address
> 00000000000100a6 du[3608]: Oops 8813272891392

Can you run these through ksymoops and provide the version of the 2.4.27
kernel you're running?

-- 
---------------------------
dann frazier
Hewlett-Packard
Linux and Open Source Lab
dannf@hp.com

