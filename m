From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 13 Sep 2010 18:33:33 +0000
Subject: [git pull] ia64 changes
Message-Id: <4c8e6e7d7613e2f70@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

---

I committed the fix for this last week prior to your -rc4 announcement
reminding us to give proper "Reported-by:" credit.  This one should have
had:

Reported-by: Tony Ernst <tee@sgi.com>

and also

Much-useful-investigation-and-tracing-by: Hedi Berriche <hedi@sgi.com>
Much-useful-investigation-and-tracing-by: Petr Tesarik <ptesarik@novell.com>

 arch/ia64/kernel/fsys.S |   46 +++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 39 insertions(+), 7 deletions(-)

Tony Luck (1):
      [IA64] fix siglock

