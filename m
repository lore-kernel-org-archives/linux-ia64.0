From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 23 Feb 2000 00:02:41 +0000
Subject: Re: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204959@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 22 Feb 2000 16:01:41 -0700, Don Dugger <n0ano@valinux.com> said:

  Don> Also, there would have to be some changes to the kernel.  This
  Don> would create ELF64 processes that have to live within the first
  Don> 4G of memory.  We already support 32-bit processes but some
  Don> kernel changes would be required to identify this new entity.

Actually, the forthcoming kernel patch already has a per-process
mmap-base.  So the only change required in the kernel would be to
recognize ILP32 binaries and set the mmap-base accordingly (so, yeah,
I lied when I said no changes would be required... ;-).  (This doesn't
mean that I think ILP32 support is a good idea...)

	--david


