From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 19:15:16 +0000
Subject: RE: __you_cannot_kmalloc_that_much
Message-Id: <marc-linux-ia64-105605023109889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604765306485@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604765306485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 19 Jun 2003 12:03:43 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> undefined reference to `local symbols in discarded section .exit.text'

  Tony> message.  Is this related to the warning about using an old linker?

Not likely.  It sounds like a driver is failing to use __exit_p() (see
linux/init.h).

	--david
