From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Nov 2008 21:47:58 +0000
Subject: RE: [PATCH V2 0/2] enable irqs when waiting for rwlocks
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35BE0554D@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224777451.11530.52.camel@elijah.suse.cz>
 <1225443142.6825.4.camel@elijah.suse.cz>
 <57C9024A16AD2D4C97DC78E552063EA35A7ED9D3@orsmsx505.amr.corp.intel.com>
 <20081103114638.GD8483@sgi.com>
In-Reply-To: <20081103114638.GD8483@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Petr Tesarik <ptesarik@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Just a few years of experiencal evidence.  The equivalent of this patch
> has been in the SuSE SLES10 kernel for years and not been detected as
> being negative.

That's good to know.

Petr: I tried to apply these ... but the patches seem corrupted
(leading spaces dropped? ... I checked in the marc.info archive
and they seem broken there too).  Can you regenerate them and
repost (attachments are ok).

-Tony
