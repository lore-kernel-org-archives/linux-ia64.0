From: "Carlos O'Donell" <carlos@baldric.uwo.ca>
Date: Sun, 12 Sep 2004 15:01:09 +0000
Subject: [Q] Why is compat_uid_t a u16 value?
Message-Id: <20040912150108.GO1854@baldric.uwo.ca>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64-ml,

The ia32 emulation code is using 'unsigned int' for uid_t returned back
to userspace. While the compat.h definitions uses compat_uid_t, which
is defined as u16. Is this correct? I would assume that compat_uid_t
should be u32 under ia64.

Is there any reason it is currently defined as u16? 
Is the compat.h definition of compat_uid_t ever used anywhere?

I'm testing some patches to cleanup compat code, but I noticed some
discrepancies in the ia64 definitions of compat.h.

Cheers,
Carlos.

