From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Jul 2002 21:24:08 +0000
Subject: Re: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
Message-Id: <marc-linux-ia64-105590701905766@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Jul 2002 11:05:19 -0600, Khalid Aziz <khalid@fc.hp.com> said:

  Khalid> Absolutely. xconfig parser has major problems with the
  Khalid> following patch to arch/ia64/config.in in 020622:

  Khalid> +else # ! HP_SIM
  Khalid> +mainmenu_option next_comment
  Khalid> +comment 'Block devices'
  Khalid> +tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
  Khalid> +dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD
  Khalid> $CONFIG_NET
  Khalid> +
  Khalid> +tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
  Khalid> +if [ "$CONFIG_BLK_DEV_RAM" = "y" -o "$CONFIG_BLK_DEV_RAM" = "m" ]; then
  Khalid> +   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
  Khalid> +fi
  Khalid> +endmenu

  Khalid> xconfig parser looks at this definition of 'Block devices'
  Khalid> and the one in drivers/block/Config.in and considers them
  Khalid> duplicates inspite of the conditional. With this patch, you
  Khalid> can not configure loopback device or RAM disk unless you are
  Khalid> configuring for HP Simulator.

  Khalid> Without the patch I sent, "make xconfig" won't even
  Khalid> start. So this patch only makes xconfig atleast partially
  Khalid> usable.

If nobody wants to fix this problem, perhaps what we should do is
change "make xconfig" so it just prints a message telling the user to
do "make menuconfig" instead.  Other suggestions (and particular patches)
are welcome...

	--david

