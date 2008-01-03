From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Jan 2008 21:48:42 +0000
Subject: RE: [PATCH] ia64: cleanup header comments in mca related files
Message-Id: <1FE6DD409037234FAB833C420AA843EC388F13@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <476B3AF5.7030309@jp.fujitsu.com>
In-Reply-To: <476B3AF5.7030309@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This looks like a nice cleanup in general (though I'm not really sure
how much we benefit by having e-mail addresses inside <...> style
brackets rather than parentheses :-).

One possible worry is this bit: 
  * Copyright (C) 2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) David Mosberger-Tang <davidm@hpl.hp.com>

While this is in the same style as all the following entries, David
didn't explicitly claim copyright for himself with the old text, just
for Hewlett-Packard with a following note that he made the change.
You added the "Copyright (C)" against his name, and that doesn't
look like a good thing to do.

-Tony
