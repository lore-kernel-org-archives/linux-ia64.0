From: dann frazier <dannf@hp.com>
Date: Wed, 30 Jun 2004 22:50:44 +0000
Subject: Re: Linker bug in Debian unstable?
Message-Id: <20040630225044.GC15816@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040630192143.GE30334@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 30, 2004 at 08:21:43PM +0100, Matthew Wilcox wrote:
> The reloc has gone, but presumably it should still be there as g_type_init()
> is part of glib-2.0.
> 
> NB: This problem currently prevents mozilla from running.  Probably other
> gnome apps too ...
> 

fyi, see debian bug #256955 & the stuff I added today to #252550.
I've started running a deb I built w/ the latest binutils so I can more
easily detect these issues.

debian/sid/gnome seems to be running fine for me again.
-- 
---------------------------
dann frazier
Hewlett-Packard
Linux and Open Source Lab
dannf@hp.com

