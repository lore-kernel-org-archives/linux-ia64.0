From: Tim Riker <TimR@CalderaSystems.com>
Date: Tue, 29 Aug 2000 20:07:18 +0000
Subject: Re: [Linux-ia64] Problem with QLogic
Message-Id: <marc-linux-ia64-105590678205414@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205399@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205399@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Uros,

I see your back at work after IDF. ;-) How dod your talk go?

What are you using to boot test7 with, lilo or eli? Just curious.

Uros Prestor wrote:
> 
> Holger Berger wrote:
> 
> > does the usage of BIOS 59 solve the SCSI timeout problems
> > or does it solve the problem that I can not access the QLogic BIOS?
> 
> No, it doesn't.  If you have a BugSur and you try entering Qlogic
> BIOS by pressing Alt-Q the system will hang.
> 
> > I read that usage of older ELI or lilo should also solve some sort of
> > SCSI timeout problems. It does not for our boxes...
> 
> If you get SCSI timeouts this usually means that IRQ routing setup is
> wrong.  Neither lilo nor eli incorporated full ACPI support yet.  The
> solution is to use 2.4.0-test7 kernel plus the latest IA-64 patch.  This
> patch has support for ACPI parsing which means that it should be able to
> correctly set up IRQ routing from the ACPI tables.  I have tested test7
> on a 2P BigSur with BIOS 60 and it works without problems.

PS: join #ia64Linux on irc.openprojects.net for live chat
-- 
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.

