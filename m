From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Sep 2003 16:06:32 +0000
Subject: RE: 2.6 mca_asm.S VA to PA mappings
Message-Id: <marc-linux-ia64-106493807000651@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106490506400881@msgid-missing>
In-Reply-To: <marc-linux-ia64-106490506400881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Slight confusion.  DATA_VA_TO_PA needs to be replaced by 
> LOAD_PHYSICAL, but what replaces DATA_PA_TO_VA in a
> non-identity mapped kernel?

Good question!  I'll start looking at that.

-Tony
