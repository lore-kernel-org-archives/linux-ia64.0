From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Aug 2003 06:06:48 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106015002132453@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Aug 2003 16:00:28 +1000, Martin Pool <mbp@samba.org> said:

  Martin> As of linux-2.6.0-test2-ia64-030729, there seems to be no
  Martin> asm-ia64/floppy.h, and so the fd driver won't work.

  Martin> Might this patch to make sure it does not accidentally get
  Martin> configured on be accepted?

Perhaps the check should be against ISA instead?  Or are there non-ISA
systems with such a floppy controller?  In any case, the final
decision of course rests with the maintainer of block/Kconfig
(probably best to bring it up on lkml).

	--david

  Martin> --- linux-2.6.0test2-ia64/drivers/block/Kconfig.~1~	2003-07-29 12:07:02.000000000 +1000
  Martin> +++ linux-2.6.0test2-ia64/drivers/block/Kconfig	2003-08-06 15:55:16.000000000 +1000
  Martin> @@ -6,7 +6,7 @@ menu "Block devices"
 
  Martin> config BLK_DEV_FD
  Martin> tristate "Normal floppy disk support"
  Martin> -	depends on !X86_PC9800
  Martin> +	depends on !X86_PC9800 && !IA64
  Martin> ---help---
  Martin> If you want to use the floppy disk drive(s) of your PC under Linux,
  Martin> say Y. Information about this driver, especially important for IBM


  Martin> -- 
  Martin> Martin 
  Martin> -
  Martin> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
  Martin> the body of a message to majordomo@vger.kernel.org
  Martin> More majordomo info at  http://vger.kernel.org/majordomo-info.html
