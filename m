From: Bill Nottingham <notting@redhat.com>
Date: Wed, 08 Nov 2000 18:41:02 +0000
Subject: [Linux-ia64] Re: fix for hang on rmmod
Message-Id: <marc-linux-ia64-105590678205672@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
> Here is a patch that should fix the problem with "rmmod" hanging.
> I don't use modules much, but I tried Stephane's test case and
> rmmod seems to work fine on it.
> 
> Thanks to Asit for tracking this down.

Hm, a kernel with this now hangs for me on *load* of the eepro100 driver.
I'll try again with a newer kernel (this was with test9-1031), and
also on a different machine.

Bill

