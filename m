From: Jes Sorensen <jes@sgi.com>
Date: Sat, 27 Jan 2007 22:49:25 +0000
Subject: Re: [PATCH] Fix NULL-pointer dereference in ia64_machine_kexec()
Message-Id: <45BBD6F5.6040801@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <eparjg$nhq$1@sea.gmane.org>
In-Reply-To: <eparjg$nhq$1@sea.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bernhard Walle wrote:
> Hello Jes,
> 
> * Jes Sorensen <jes@sgi.com> [2007-01-27 07:28]:
>>>>>>> "Bernhard" = Bernhard Walle <bwalle@suse.de> writes:
>> Bernhard> printk(KERN_NOTICE "Kdump not configured\n");
>>
>> Wouldn't it make more sense to make that messages a bit more
>> descriptive? Ie. include something about what it tried to do when it
>> noticed it wasn't configured?
> 
> Do you think 
> 
>     machine_kdump_on_init(): kdump not configured
> 
> would be better? That would make it easier to find the position of the
> message in code. Or did you think of a more verbal description like

That would do just fine I think, anything to avoid having to run find
and grep on the tree to figure out where it came from :)

Cheers,
Jes
