From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Wed, 06 Apr 2005 03:32:02 +0000
Subject: Re: [patch] add MCA recovery on/off switch
Message-Id: <42535832.2030903@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504060327.j363REMp8976934@clink.americas.sgi.com>
In-Reply-To: <200504060327.j363REMp8976934@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> Create /proc/sys/kernel/mca_recovery to turn on/off the MCA recovery code.
> This allows the recovery code to be enabled or disabled without having
> to reboot.

Is there also a way to disable MCA recovery on the command line
as a boot option?  Using sysctl for it could be too late.

> 1 indicates MCA recovery is on.
> 0 indicates MCA recovery is off.
> 
> Signed-off-by: Russ Anderson <rja@sgi.com>


-- 
~Randy
