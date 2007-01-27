From: Jes Sorensen <jes@sgi.com>
Date: Sat, 27 Jan 2007 06:28:19 +0000
Subject: Re: [PATCH] Fix NULL-pointer dereference in ia64_machine_kexec()
Message-Id: <yq0odolq8zg.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <eparjg$nhq$1@sea.gmane.org>
In-Reply-To: <eparjg$nhq$1@sea.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bernhard" = Bernhard Walle <bwalle@suse.de> writes:

Bernhard> printk(KERN_NOTICE "Kdump not configured\n");

Hi Bernhard,

Wouldn't it make more sense to make that messages a bit more
descriptive? Ie. include something about what it tried to do when it
noticed it wasn't configured?

Cheers,
Jes
