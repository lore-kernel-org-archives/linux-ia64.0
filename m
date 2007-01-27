From: Bernhard Walle <bwalle@suse.de>
Date: Sat, 27 Jan 2007 13:15:14 +0000
Subject: Re: [PATCH] Fix NULL-pointer dereference in ia64_machine_kexec()
Message-Id: <20070127131514.GA30463@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <eparjg$nhq$1@sea.gmane.org>
In-Reply-To: <eparjg$nhq$1@sea.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Jes,

* Jes Sorensen <jes@sgi.com> [2007-01-27 07:28]:
> >>>>> "Bernhard" = Bernhard Walle <bwalle@suse.de> writes:
> 
> Bernhard> printk(KERN_NOTICE "Kdump not configured\n");
> 
> Wouldn't it make more sense to make that messages a bit more
> descriptive? Ie. include something about what it tried to do when it
> noticed it wasn't configured?

Do you think 

    machine_kdump_on_init(): kdump not configured

would be better? That would make it easier to find the position of the
message in code. Or did you think of a more verbal description like

    tried to dump but that's not possible because kdump was
    not configured (ia64_kimage = NULL)

But I think we shouldn't write novels in the kernel log. ;)

But feel free to suggest another proposal and I'll update the patch. I
just want to see it included in mainline.


Regards,
Bernhard
