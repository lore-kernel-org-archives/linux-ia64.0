From: Andrew Morton <akpm@osdl.org>
Date: Thu, 28 Jul 2005 01:41:44 +0000
Subject: Re: [patch] properly stop devices before poweroff
Message-Id: <20050727184144.27aae085.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F03FCF24C@scsmsx401.amr.corp.intel.com>
	<42E836F5.2050803@jp.fujitsu.com>
In-Reply-To: <42E836F5.2050803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: tony.luck@intel.com, ambx1@neo.rr.com, greg@kroah.org, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> wrote:
>
> After all, I think ia64-halt-hangup-fix.patch should be removed
>  from -mm tree.

yup, I already tested-and-dropped it, thanks.
