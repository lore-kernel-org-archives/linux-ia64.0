From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Nov 2003 21:14:00 +0000
Subject: Re: [PATCH] Bug in sn_pci_map_sg causes MCA
Message-Id: <marc-linux-ia64-106789457014516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106789192810902@msgid-missing>
In-Reply-To: <marc-linux-ia64-106789192810902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Nov 2003 12:47:55 -0800, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> David, this fixes a critical bug for us.  Can you push it to
  Jesse> Linus or should we send it straight to Andrew?

The patch doesn't apply for me, otherwise, I'd have been happy to take
it (since it's a critical bug fix).  I think it fails to apply because
TABs got replaced by blanks.

	--david
