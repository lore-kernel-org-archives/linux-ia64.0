From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Jul 2002 18:05:50 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905802@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Jul 2002 13:54:36 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> David Mosberger <davidm@napali.hpl.hp.com> writes: |> The
  Andreas> latest ia64 kernel patch is at |>
  Andreas> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/ in
  Andreas> file: |> |> linux-2.4.18-ia64-020719.diff.gz

  Andreas> Why are you explicitly disabling CONFIG_BLK_DEV_LOOP,
  Andreas> CONFIG_BLK_DEV_NBD and CONFIG_BLK_DEV_RAM?

I generally trust Keith's build-environment related fixes.  Turned out
to be a mistake in this particular case.  I just uploaded a new
patch:

	linux-2.4.18-ia64-020722.diff.gz

It goes back to the more drastic solution of turning off "xconfig"
alltogether (it tells you to use "menuconfig" instead).  I don't care
about "xconfig" myself, but of course will welcome patches that fix
the problems for real.

The new patch also has the additional #define's needed for the tg3 driver.

	--david

