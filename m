From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 25 Jan 2002 19:33:49 +0000
Subject: [Linux-ia64] Re: [PATCH] find_next_zero_bit
Message-Id: <marc-linux-ia64-105590698805935@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Applied.

Thanks,

	--david

>>>>> On Fri, 25 Jan 2002 19:08:43 +0100 (MET), Erich Focht <efocht@ess.nec.de> said:

  Erich> Hi, the following little patch repairs the function
  Erich> find_next_zero_bit() for ia64 platforms. Somehow this small
  Erich> piece of code went lost from the ia64 version. The problem is
  Erich> that the function returns results larger than the size of the
  Erich> bitmap if all bits are set (ignores stop-bits) and the size
  Erich> is not a multiple of sizeof(long). This lead to crashes of
  Erich> Ingo's new scheduler under heavy load.

  Erich> Regards, Erich


  Erich> --- 2.4.17-ia64-kdb-j6/include/asm-ia64/bitops.h Tue Jan 15
  Erich> 15:21:08 2002 +++
  Erich> 2.4.17-ia64-kdb-j6ia64/include/asm-ia64/bitops.h Fri Jan 25
  Erich> 19:45:31 2002 @@ -357,6 +357,8 @@ tmp = *p; found_first: tmp
  Erich> |= ~0UL << size; + if (tmp = ~0UL) /* Are any bits zero? */
  Erich> + return result + size; /* Nope. */ found_middle: return
  Erich> result + ffz(tmp); }

