From: Chris Wedgwood <cw@f00f.org>
Date: Sun, 12 Sep 2004 19:55:31 +0000
Subject: Re: [Q] Why is compat_uid_t a u16 value?
Message-Id: <20040912195531.GA8530@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040912150108.GO1854@baldric.uwo.ca>
In-Reply-To: <20040912150108.GO1854@baldric.uwo.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Sep 12, 2004 at 11:01:09AM -0400, Carlos O'Donell wrote:

> The ia32 emulation code is using 'unsigned int' for uid_t returned
> back to userspace. While the compat.h definitions uses compat_uid_t,
> which is defined as u16.

Some older parts of the x86 ABI use a 16-bit UID in places (sysv IPC
and stat probably, I didn't check).

> Is this correct? I would assume that compat_uid_t should be u32
> under ia64.

Then running applications using the old x86 ABI would break.
