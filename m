From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Jul 2000 15:09:04 +0000
Subject: Re: [Linux-ia64] Support for more than 2GB RAM
Message-Id: <marc-linux-ia64-105590678205204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 18 Jul 2000 14:40:42 +0200, Christoph Rohland <cr@sap.com> said:

  Christoph> Hi, Are there any plans to support more than 2GB RAM in
  Christoph> the near future?

There never was a limit for 2GB.  4GB is no problem and more than 4GB
works fine also except if there are 32-bit PCI devices that do DMA (or
the machine has huge holes in the physical address space, which isn't
true for the prototypes).  For the DMA issue, a solution is in the
works (Goutham has been working on this).

	--david


