From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 06 Aug 2003 06:33:10 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106015160201075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Aug 2003 16:19:19 +1000, Martin Pool <mbp@samba.org> said:

  Martin> Are there any ia64 machines which come with floppy drives?

Nope.  The Merced machines came with SuperDrives (or whatever they
were called), but those attached to the IDE controller, not the floppy
controller.  The classic (AT-style) floppy controller is an ISA device
and since ia64 doesn't support ISA, such controllers never were
supported.

	--david
