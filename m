From: Matt_Domsch@Dell.com
Date: Fri, 05 Jan 2001 19:22:12 +0000
Subject: RE: [Linux-ia64] fdisk for efi disks?
Message-Id: <marc-linux-ia64-105590678205886@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205863@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205863@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'm a new kid on the block and I was interested if anyone was already
> working on an fdisk replacement/enhancement to be used on efi disks?

I started work to add GPT support to GNU parted, but made it for 1.2.x, not
the current 1.4.x, and haven't had the time to do the forward-port.  If
you've got the time, I'm happy to send you my original patch.

> I wonder if enhancing fdisk such that it also handles efi 
> disks would be
> better than building a new tool (efdisk)?

Modifying fdisk would be useful too, IMHO.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team


