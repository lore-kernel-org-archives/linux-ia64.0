From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 03 Aug 2001 01:08:07 +0000
Subject: Re: [Linux-ia64] efibootmgr-0.3.3-test5
Message-Id: <marc-linux-ia64-105590693005997@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,
> 
> Given that you can have load options with the same name (for whatever good
> it does), how might people want to see this fixed?
> 1) Warn the user, but do it anyway.  Probably doesn't help the installer app
> that calls efibootmgr.
> 2) Warn the user, do it anyway, append text to it like [1].  Not too pretty.
> 3) Warn the user, don't do it, need yet another flag to force it.
> 4) Make installer app more intelligent, something like:
> 	for b in `efibootmgr | grep "Red Hat Linux" | awk '{print $1}'`; do 
> 		efibootmgr -b $b -B
> 	done
> 
> 
> I prefer 4 myself, but could see adding 1) if desired.
> 
Clearly the installer should do 4) but a warning would be good too.

-- 

-Stephane

