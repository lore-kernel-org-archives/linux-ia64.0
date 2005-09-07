From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 07 Sep 2005 19:12:45 +0000
Subject: RE: [patch] delete sync.i in ia64_switch_to()
Message-Id: <200509071913.j87JDOg01754@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070723.j877N9g25144@unix-os.sc.intel.com>
In-Reply-To: <200509070723.j877N9g25144@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Hull wrote on Wednesday, September 07, 2005 10:33 AM
> That sync.i is not old code - it is required.
> 
> It is not there to handle kernel fc instructions - as you say, they have
> their own sync instructions.  The sync.i in the context switch path is there
> to guarantee that user-mode fc's become visible.

Thank you for the explanation.  Now I see the lights :-)

- Ken

