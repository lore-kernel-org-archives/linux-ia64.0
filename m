From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 10 May 2001 04:14:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.4)
Message-Id: <marc-linux-ia64-105590693005561@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 May 2001 09:21:49 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> BTW, The SN platform does have a hi-res synchronized clock that can be
  Jack> mmapped & read from user space. The clock is located in the "chipset"
  Jack> and is synchronized across all nodes/FSBs.

Good. This was indeed the working assumption: on machines where ITCs
aren't synchronous, there needs to be some other mechanism to obtain
fine-grained time stamps.  So, I think what you'll need is a device
driver for your chipset which will allow mapping the hi-res clock into
user space where libc can use it to implement the *clock* routines.
In the kernel, we can make gettimeoffset() a platform-specific
function, so SN1 and other platforms with non-synchronous clocks can
use an external hi-res timer to implement it.

The only challenge is to decide when to use ITCs and when to use other
hardware.  Unfortunately, I don't believe SAL provides info on whether
the ITC clocks are synchronized (I think it should!).  For now, we
could implement it such that an external hi-res timer is used in favor
of ITCs whenever such hardware is present.

	--david

