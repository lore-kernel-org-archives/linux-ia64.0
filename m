From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 05 Mar 2003 22:19:25 +0000
Subject: Re: [Linux-ia64] (no subject)
Message-Id: <marc-linux-ia64-105590709805977@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205296@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205296@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> im trying to install mandrake on a 64 bit itanium machine. i can't get the cd 
> drive to be recognized in the fsX format. it instead shows up as blk4 and 
> consequently i can't read the files on the damn cd nor can i use the elilo 
> command.
> does anyone know if this is a hardware issue or if i can somehow get the cd 
> drive to show up as fs something...

This is an ia64 CD, right?  EFI might recognize an x86 CD, but you
certainly wouldn't be able to install from it.

If you insert the CD after power-up, you may have to do "map -r" to
get EFI to look at the media and figure out there's a filesystem there.

Bjorn


