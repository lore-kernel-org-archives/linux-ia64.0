From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 16 Dec 2004 22:43:05 +0000
Subject: Re: [PATCH] 2.6.10 Altix : ioc4 serial driver support
Message-Id: <20041216224304.GE7113@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com>
In-Reply-To: <200412162224.iBGMOQ52284713@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Dec 16, 2004 at 04:24:26PM -0600, Pat Gefre wrote:
> I have a serial driver for Altix I'd like to submit.

Why put it in arch/ia64/sn/io/sn2/driver/ioc4_serial.c ?!
drivers/serial/ioc4.c would be the right place for it.  You put the
Kconfig there -- that should be a clue.

It seems like you're directly dereferencing pointers to io memory instead
of calling readb and friends.  I know, this driver doesn't need to be
portable, but it helps any casual reader of this driver figure out what's
going on.  And you can get rid of the 'volatile' that way ;-)

Linux Device Drivers, Second edition says you shouldn't use SA_INTERRUPT
without good reason (http://www.xml.com/ldd/chapter/book/ch09.html#t3)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
