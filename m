From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 26 Sep 2001 22:34:58 +0000
Subject: Re: [Linux-ia64] ia64_log_get: Failed to retrieve SAL error record type 3
Message-Id: <marc-linux-ia64-105590698805257@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805254@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805254@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 26 Sep 2001 17:23:51 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> I'm repeatedly (endlessly) getting the message $subject on
  Andreas> a Lion.  What does that mean?

It's a sign that you need to upgrade your firmware.  My understanding
is that you need at least revision 94 which, AFAIK, has not been
released yet.  Could someone from Intel comment please?

One thing I forgot to mention in my 2.4.10 patch announcement: you'll
also see a bunch of ACPI warning messages with the new kernel.  Those
are harmless: the ia64 linux kernel is currently a bit lazy about
marking physical memory areas used for I/O as "reserved" and that's
why ACPI is complaining.  I suppose if someone wanted to use PCMCIA or
other hotpluggable devices, this could become a real problem.  It's
certainly something that will have to be fixed in the not too distant
future.

	--david

