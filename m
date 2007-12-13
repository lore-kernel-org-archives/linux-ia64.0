From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Dec 2007 00:45:03 +0000
Subject: RE: [PATCH 4 of 4] Add efi_guidtest_set to reduce duplication
Message-Id: <1FE6DD409037234FAB833C420AA843EC16445A@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <81b2361265e2950b6a62.1197472071@jenkins.nashua>
In-Reply-To: <81b2361265e2950b6a62.1197472071@jenkins.nashua>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Would you like me to regenerate patch 1/4 without the reformatting of
> those tests, so they maintain the original long-lines?

I'm not a big fan of the 80 column rule ... but this file is
a bit out of control ... and all the other bizarre formatting
that you fixed up looks like an improvement.

The patch needs a refresh anyway (4 of the hunks failed to auto-apply
... presumably because of Li Zefan's change to use efi_md_size()
everywhere).  Please leave out the efi_guidcmp() lines (the worst
one is only 92 chars long) in the refresh.

-Tony
