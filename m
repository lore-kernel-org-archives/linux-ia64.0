From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 May 2002 00:53:25 +0000
Subject: Re: [Linux-ia64] kernel boot failure
Message-Id: <marc-linux-ia64-105590701905607@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905606@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905606@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 28 May 2002 17:35:14 -0700 (PDT), Chris Blazie <cblazie@yahoo.com> said:

  Chris>      So there must be a hardware or firmware problem here.
  Chris> But before we begin swapping parts and/or upgrading the bios,
  Chris> I wrote down the boot messages leading to the hang (and panic
  Chris> in a separate case) in hopes someone here could shed some
  Chris> light on what stage of the boot process is failing (and maybe
  Chris> why).

The "Error: only one processor found" message isn't a fatal error
message (it really ought to say "Warning:...", but that's another
story...).  I don't recall seeing issues like the ones you describe.
It does sound like it might be a hardware failure.  Probably best to
contact the hw support folks.

	--david

