From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 02 Jun 2003 18:39:24 +0000
Subject: RE: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706113@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 2 Jun 2003 11:34:02 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> TLB recovery was chosen as the first piece as it appears to be
  Tony> the simplest to implement,

Ah, I see.

  Tony> though its probably one of the lowest value adds (frequency of
  Tony> TLB errors should be *far* lower than memory errors

Yes, I guess that's what surprised me.

	--david

