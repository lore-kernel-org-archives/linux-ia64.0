From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 05 Jan 2002 06:59:40 +0000
Subject: [Linux-ia64] instant reset with dfe-530tx network card
Message-Id: <marc-linux-ia64-105590698805748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After installing a D-Link DFE-530TX network adapter in a Big Sur, the
machine fails to boot: it resets right at the point where the EFI
shell should come up.  Has anyone else seen this?

I have only tried on one machine so far, but the reset is clearly due
to the network card: if I remove it, the machine boots just fine.  I
also tried different PCI slots, to no avail.  Actually, I only tried
the 3.3V slots; perhaps I should have tried the 5V slot.  I'll try
that later.  The firmware is build 117a.

	--david

