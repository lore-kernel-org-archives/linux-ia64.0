From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Jun 2006 06:01:54 +0000
Subject: RE: [PATCH] printing support for MCA/INIT
Message-Id: <617E1C2C70743745A92448908E030B2A0EE79F@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4486BE32.80100@jp.fujitsu.com>
In-Reply-To: <4486BE32.80100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I guess there are only 2 cases actually needs to display its progress,
> long time wait on rendezvous and INIT-monarch. 

In the MCA case, something bad has already happened to the system,
it is possible that we will not complete printing all of the
messages, but if they are streaming directly to the console, then
at least we will see the first part of the messages.  If you buffer
them to be printed later, there may be no "later", and all the
information will be lost.

-Tony
