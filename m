From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 03 Jan 2011 18:18:22 +0000
Subject: RE: ia64 lockdep patch prepared for linux 2.6.38
Message-Id: <987664A83D2D224EAE907B061CE93D530193EF8F1B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
In-Reply-To: <AANLkTimJ3au7G+kUA1CjPxzySGnuaPRVJgssjbXSeSu+@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> if you can get the patch merged into your test branch

My test branch is pulled into each linux-next build ... and there
are some generic changes at the end of your patch that I don't
understand - but they look like they will affect other architectures.

What are INIT_{SOFT,HARD}_IRQFLAGS for? Why do we need to add them
for ia64?

-Tony
