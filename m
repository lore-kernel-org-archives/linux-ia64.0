From: Matt_Domsch@Dell.com
Date: Thu, 02 Aug 2001 21:26:27 +0000
Subject: RE: [Linux-ia64] efibootmgr-0.3.3-test5
Message-Id: <marc-linux-ia64-105590693005994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We have noticed (during RH7.1) install that efibootmgr was 
> not checking
> for options with an identical names and it was creating menu options
> with the same name for instance if you reinstall the system a 
> second time.
> 
> Would it be possible to add a warning/error/check that would 
> avoid such a thing ?

Given that you can have load options with the same name (for whatever good
it does), how might people want to see this fixed?
1) Warn the user, but do it anyway.  Probably doesn't help the installer app
that calls efibootmgr.
2) Warn the user, do it anyway, append text to it like [1].  Not too pretty.
3) Warn the user, don't do it, need yet another flag to force it.
4) Make installer app more intelligent, something like:
	for b in `efibootmgr | grep "Red Hat Linux" | awk '{print $1}'`; do 
		efibootmgr -b $b -B
	done


I prefer 4 myself, but could see adding 1) if desired.

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

