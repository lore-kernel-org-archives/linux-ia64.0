From: "Eric S. Raymond" <esr@thyrsus.com>
Date: Tue, 01 May 2001 19:37:26 +0000
Subject: Re: [Linux-ia64] Request for Configure.help texts for IA64 option s.
Message-Id: <marc-linux-ia64-105590693005504@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005502@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005502@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt_Domsch@Dell.com <Matt_Domsch@Dell.com>:
> > CONFIG_IA64_EFIVARS
> 
> CONFIG_IA64_EFIVARS has been replaced with CONFIG_EFI_VARS in what will be
> DavidM's next patch against 2.4.4, and his tree includes help text for this.

Heh.  I remember looking at this and thinking the underscore was missing.

> I'm including it here just for reference.
> 
> /proc/efi/vars support
> CONFIG_EFI_VARS
>   If you say Y here, you are able to get EFI (Extensible Firmware
>   Interface) variable information in /proc/efi/vars.  You may read,
>   write, create, and destroy EFI variables through this interface.
> 
>   To use this option, you have to check that the "/proc file system
>   support" (CONFIG_PROC_FS) is enabled, too.

I've added this to my superset-merged Configure.help.
-- 
		<a href="http://www.tuxedo.org/~esr/">Eric S. Raymond</a>

Let us hope our weapons are never needed --but do not forget what 
the common people knew when they demanded the Bill of Rights: An 
armed citizenry is the first defense, the best defense, and the 
final defense against tyranny.
   If guns are outlawed, only the government will have guns. Only 
the police, the secret police, the military, the hired servants of 
our rulers.  Only the government -- and a few outlaws.  I intend to 
be among the outlaws.
        -- Edward Abbey, "Abbey's Road", 1979

