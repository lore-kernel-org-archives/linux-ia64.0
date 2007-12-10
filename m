From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Dec 2007 23:07:32 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC0FD6B5@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
> makes the Makefile work even for a non-executable file for when you use 
> inferior tools, but does that mean that we should have thrown away the 
> information that it *is* an executable file when not using those inferior 
> tools?

Once I added the "python " in front of the name in the Makefile, the need
for it to be executable went away ... so I did the chmod deliberately as
it looked like we didn't need the execute bit any more.

This is only wrong if there are people in the habit of running
arch/ia64/scripts/unwcheck.py manually from the command line.
I've never done this ... but perhaps someone might be sad that
I took the execute bit away.

-Tony
