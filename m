From: Jared Egolf <jegolf@yahoo.com>
Date: Fri, 16 Nov 2001 21:42:35 +0000
Subject: [Linux-ia64] kernel panic on root mount / EFI cant see
Message-Id: <marc-linux-ia64-105590698805531@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805521@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805521@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you very much for your reply.  I did double check and
I am having this problem on a system where the partition
type is set to 'ef'.  It doesn't seem to matter which
partition type I attempt to use.
-- Jared Egolf

> From: Bdale Garbee <bdale@gag.com>
> Date: Thu, 15 Nov 2001 17:47:42 -0700

> jegolf@yahoo.com (Jared Egolf) writes:

>> Using Redhat 7.2 and in the past 7.1, I cannot configure
>> the /boot/efi partition with such a type definition that
>> EFI will recognize the file-system and thus use it for
>> booting purposes.

> FYI, it appears the defined partition type for EFI FAT is
'ef', and for 
> EFI GPT it's 'ee'.  Debian currently requires that you
use 'ef'.

> Modern versions of fdisk, cfdisk, et al know these
types...

> Bdale


__________________________________________________
Do You Yahoo!?
Find the one for you at Yahoo! Personals
http://personals.yahoo.com

