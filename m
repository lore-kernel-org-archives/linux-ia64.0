From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Wed, 08 Nov 2000 18:50:44 +0000
Subject: RE: [Linux-ia64] Re: fix for hang on rmmod
Message-Id: <marc-linux-ia64-105590678205673@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205672@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205672@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Folks,

I have never seen this problem ( test10 ). This is with the Intel e100 and
e1000 drivers.
You folks have updated modutils?

--ken

> -----Original Message-----
> From:	Bill Nottingham [SMTP:notting@redhat.com]
> Sent:	Wednesday, November 08, 2000 10:41 AM
> To:	David Mosberger
> Cc:	linux-ia64@linuxia64.org
> Subject:	[Linux-ia64] Re: fix for hang on rmmod
> 
> David Mosberger (davidm@hpl.hp.com) said: 
> > Here is a patch that should fix the problem with "rmmod" hanging.
> > I don't use modules much, but I tried Stephane's test case and
> > rmmod seems to work fine on it.
> > 
> > Thanks to Asit for tracking this down.
> 
> Hm, a kernel with this now hangs for me on *load* of the eepro100 driver.
> I'll try again with a newer kernel (this was with test9-1031), and
> also on a different machine.
> 
> Bill
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


