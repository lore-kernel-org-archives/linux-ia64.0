From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Dec 2007 23:21:47 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC0FD70D@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Hmm. It also did:
>
>   mode change 100755 => 100644 arch/ia64/scripts/unwcheck.py

Should I update my script that makes the "Please pull" message.
Right now it just uses "git whatchanged release ^linus | git-shortlog"
which doesn't mention any mode changes ... thus your understandable
confusion about whether I had meant to make this change.

What git command would neatly summarize any mode changes?  Or would
I have to roll my own from the whatchanged output?

-Tony
