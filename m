From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 25 Aug 2003 09:03:31 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
Message-Id: <marc-linux-ia64-106180221407470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Pool <mbp@samba.org> writes:

Martin> On 5 Aug 2003, David Mosberger <davidm@napali.hpl.hp.com>
Martin> wrote:
>>  Perhaps the check should be against ISA instead?  Or are there
>> non-ISA systems with such a floppy controller?  In any case, the
>> final decision of course rests with the maintainer of block/Kconfig
>> (probably best to bring it up on lkml).

Martin> Other systems (such as Amiga and m68k) have non-ISA floppy
Martin> drives, which are reached through an ad-hoc abstraction layer
Martin> defined by different implementations of asm/floppy.h:

Catching up on old mail here, however Amiga never used the standard
style floppy driver, we had our own. I think there is one m68k based
box which used the ISA style one.

Sparc also uses drivers/block/floppy.c and they don't have ISA.

Cheers,
Jes
