From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 02 Jun 2003 16:42:30 +0000
Subject: Re: [Linux-ia64] Re: hp_simserial_driver required for real kernel
Message-Id: <marc-linux-ia64-105590723706108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706089@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706089@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Will,

On Fri, May 30, 2003 at 03:30:51PM -0400, Will Cohen wrote:
> I hacked around the offending code in the arch/ia64/hp/sim, so things 
> linked and booted.
> 
> Unfortunately, I am doing this on a Intel ia64 machine. I don't 
> currently have a Longs Peak machine. However, given that things work for 
> a Long's Peak it should be a simple edit of arch/ia64/Makefile to 
> exclude building the simulator for a workaround until the simulator gets 
> fixed.
> 

This has been fixed by Changeset 1.1079 in the BK tree for 2.5.

-- 

-Stephane

