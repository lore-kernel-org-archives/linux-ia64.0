From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 07 Dec 2000 21:57:18 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.0-test11)
Message-Id: <marc-linux-ia64-105590678205817@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  David> CAVEAT: the kernel now relies on PAL_VM_SUMMARY returning the
  David> correct value for IMPL_VA_MSB.  If you have old firmware,
  David> this may cause the kernel to fail to boot.  To find out, look
  David> for the message of the form:

  David> 	CPU 0: XX virtual and YY physical address bits

  David> if XX is anything other than 50, you need to upgrade your
  David> firmware.

Make that 51 (IMPL_VA_MSB is 50 on Itanium, i.e., the number of
virtual address bits is 51; some day I'll get this right... ;-)

Thanks to Matt for pointing this out and sorry for the confusion.

You can check whether your firmware is recent enough by doing:

	fgrep Virtual /proc/pal/cpu0/vm_info

If it displays "51 bits", you're in fine shape.

	--david

