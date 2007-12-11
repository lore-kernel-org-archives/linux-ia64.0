From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Dec 2007 17:45:40 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC11F58D@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I thought you already generated the diffstat with "git diff --stat", and 
> if so, just adding "--summary" should do it.

My script was written in the early hours (well weeks) of git history. Perhaps
I didn't know about "--stat" or maybe it didn't exist yet. The script
currently just pipes "git-whatchanged -p" output to "diffstat -p1".  I'll
update it with this new fancy "..." syntax and use the --summary.

-Tony
