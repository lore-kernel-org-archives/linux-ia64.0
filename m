From: Uros Prestor <uros@mail.turbolinux.com>
Date: Wed, 05 Apr 2000 21:08:56 +0000
Subject: Re: [Linux-ia64] kernel panic with TL distribution
Message-Id: <marc-linux-ia64-105590678205001@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205000@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205000@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 5 Apr 2000, Ross A. Towle wrote:

> With the TL distribution I am seeing:
> 
> kernel bug at inode.c 695
> unable to handle kernel paging request at virtual address 0000000000
> as[475]: Oops 880682956800
> entering kdb due to panic @ 0x005ce930

If this happens while you are rebooting a Lion system the reason is Lion
firmware.  We are seeing kernel panics on our Lion systems even when we
upgraded to the latest firmware (BIOS build 30).

The BigSur systems with older firmware have been exhibiting the same
symptoms.  This was fixed in BIOS firmware dated after Jan 17.

Uros




