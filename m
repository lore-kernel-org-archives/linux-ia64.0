From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Jul 2002 05:04:16 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Jul 2002 13:09:24 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Memo to self: xconfig is a can of worms, try to avoid working
  Keith> on it.

Ain't that the truth!

  Keith> * Indents arch/ia64/config.in so I can see what is dependent
  Keith> on HP_SIM.  The bulk of the patch is indent changes, if this
  Keith> is a problem I can do another patch without the indent
  Keith> changes, but the result is much less readable.

  Keith> * Moves force settings of ACPI variables based on HP_SIM to
  Keith> _after_ HP_SIM is actually defined.  General config bug, not
  Keith> xconfig specific.

Good points.  I picked these up (though with as little reordering as
possible, to avoid introducing new subtle bugs).

  Keith> * Removes dependency on CONFIG_DRM_AGP.  That variable does
  Keith> not exist and breaks xconfig for ia64.  This is a generic
  Keith> 2.4.18/2.4.19-rc bug and has been sent to Marcelo.

Makes sense.  I see you alread submitted this fix to Marcelo.  I picked
it up, too.

  Keith> * Moves force setting of DEVFS for SN[12] to fs/Config.in.

  Keith> * Removes the attempt to set BLOCK variables from
  Keith> arch/ia64/config.in and adds the dependency on HP_SIM to
  Keith> drivers/block/Config.in.  This is the only method that stands
  Keith> any chance of working for xconfig.  ACPI is already done this
  Keith> way for the same reason, the arch dependencies are inside the
  Keith> ACPI menu, not in the arch menu.

Now these I really don't like.  I don't think it's good to clutter
platform-independent config files with platform-specific info just
because xconfig is broken.  As far as I know, these things work
perfectly fine with "oldconfig", "config", and "menuconfig".  (I don't
feel as strongly about this for DEVFS as I do for HP_SIM; but clearly
HP_SIM is such a special case that I'd prefer to keep it in the
ia64-specific config file.)

	--david

