From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 15 Feb 2002 06:24:13 +0000
Subject: Re: [Linux-ia64] size of spinlock_t
Message-Id: <marc-linux-ia64-105590701905102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Feb 2002 00:14:55 -0600, Ray Bryant <raybry@engr.sgi.com> said:

  Ray> In experimenting with new numa lock implementation, I changed
  Ray> the size of spinlock_t to 16 bytes.  The resulting kernel hangs
  Ray> on our SN hardware just after printing "All processors have
  Ray> done init_idle".  Now it is possible this is something peculiar
  Ray> to the SGI kernels, but I was wondering if anyone knew of
  Ray> places in the IA64 kernel that "know" that
  Ray> sizeof(spinlock_t)=8 and don't work correctly if this is
  Ray> changed.

Are you sure it's not just include/asm/offsets.h that's out of date?
Make sure you have no stray arch/ia64/tools/print_offsets.s file and
then rerun make dep.

	--david

