From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 14 Sep 2010 17:37:12 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <987664A83D2D224EAE907B061CE93D53015DDA7B97@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Tony's fix works perfectly, but it adds more instructions than
> necessary. Optimize the fast path again.

Ah! You spotted that I just pasted in gcc -S output :-)

This looks much better.  I'll queue is up for the next merge window.

-Tony
