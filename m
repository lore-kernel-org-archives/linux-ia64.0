From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Mar 2008 17:03:06 +0000
Subject: RE: [patch 1/3] ia64: fix ptrace inside a namespace
Message-Id: <1FE6DD409037234FAB833C420AA843ECC0C596@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200803042314.m24NEwT5002321@imap1.linux-foundation.org>
In-Reply-To: <200803042314.m24NEwT5002321@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> And there we are. If we don't push the ptrace() changes into mainline
> soon, mainline will drift away from us. :(

I staged your patches into my tree yesterday ... I'll push to Linus
soon.

-Tony
