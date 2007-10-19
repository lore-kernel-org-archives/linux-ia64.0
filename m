From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Oct 2007 18:19:06 +0000
Subject: RE: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <617E1C2C70743745A92448908E030B2A02B9AB4E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The only real change from the prior version is that I change the
> intialization of socket_id to 0 as default. I think the benefit
> of displaying information from PAL/SAL (when available) on older
> platforms outweighs the oddity that the user may see physical_id
> = 0 for multiple CPUs occasionally.

Can't we not print the physical_id if we don't know what it is? That
sounds like a better idea than printing wrong information.

-Tony
