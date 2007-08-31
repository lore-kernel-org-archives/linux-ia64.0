From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 31 Aug 2007 08:53:30 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1188550410.8322.1.camel@chaos>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2007-08-31 at 01:37 -0700, Linus Torvalds wrote:
> It would appear that what you actually wanted to happen in that commit was 
> to make sure that the clocksource didn't get registered. If so, the 
> logical patch would be something like the appended instead, which would 
> disable the code that registers it the _obvious_ way, instead of 
> initializing a variable to a bad pointer and then relying on the bad 
> pointer to disable the code.
> 
> So can somebody explain to me why it was done in that really odd way? 

Oops, slipped through my attention. Indeed your #ifdef IA64 variant is
the sane solution.

	tglx


