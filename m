From: m.delahaye@esiee.fr (Matthieu Delahaye)
Date: Thu, 17 Apr 2003 13:06:00 +0000
Subject: [Linux-ia64] swiotlb on rx4610, again
Message-Id: <marc-linux-ia64-105590723705531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi guys,

I have two rx4610 which ran well until last week under Linux for more than
one year.
They ran with first an unstable and then a stable Debian Woody with the
standard stock kernel (2.4.17) provided by Debian.
I didn't change their hardware configuration since.

Thanks to an ext3 filesystem crash, I had to reinstall Linux on. Using
the same standard process I always used, no way this time to complete
the installation:
Kernel panic: map_single could not allocated software IO TLB (42 bytes)
In interrupt handler - not syncing
Looking on the second one I have, same problem.

I've isolated the problem: setting up a NIC (eepro100) and just perform a ping is enough.
I've found in this mailing list a workaround: swiotlb kernel parameter.

Providing a too high value (32768) made the system reboot before going into
Init. swiotlb@96 works well.

But the fact this kernel worked without this option and that now it is
required, I'm quite "annoyed" hoping this is not an hardware issue. Is there a known problem on rx4610 which may explain that?

Best regards,

Matthieu Delahaye





