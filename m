From: "Wang, Zhenyu Z" <zhenyu.z.wang@intel.com>
Date: Thu, 05 Aug 2004 04:27:39 +0000
Subject: RE: IA64 test report: 2.4.27-rc3 /tiger 2004-8-4: 9/9 pass, atapi ide floppy issue
Message-Id: <9DE394C12A921946AEECE1F71944ECD50F06AA@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <6E0C289723A0564F9A8279E236E8565F07CB29CC@pdsmsx402.pd.intel.com>
In-Reply-To: <6E0C289723A0564F9A8279E236E8565F07CB29CC@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 
I have no fixed available tiger, so I can't tell if the ide floppy was good before.
I'll do the check soon.

thanks,
-zhen

-----Original Message-----
From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com] 
Sent: 2004年8月4日 22:59
To: Wang, Zhenyu Z
Cc: linux-ia64@vger.kernel.org; linux-acpi
Subject: Re: IA64 test report: 2.4.27-rc3 /tiger 2004-8-4: 9/9 pass, atapi ide floppy issue

On Tuesday 03 August 2004 9:04 pm, Wang, Zhenyu Z wrote:
> End request I/O error of ATAPI IDE floppy when doing partition check. 
> Mount test ok after boot up in normal use. Enable IDEFLOPPY_DEBUG_xx and
> attach log below.

Have you tested the IDE floppy successfully in the past?  I guess there
is one in my i2000, but I've never used it.  The only recent ia64 changes
are these:

    http://lia64.bkbits.net:8080/linux-ia64-2.4/cset%40410fb7f0oHLxIevO1wEZvNUF8HZWWQ
    http://lia64.bkbits.net:8080/linux-ia64-2.4/cset%40410fb812uAceYTVmx9ANHTFVmyTp9A

so you might try backing them out to start.  If those have no effect,
it's likely an upstream problem, and you might drop a note to the IDE
floppy maintainer.

Don't those things take special media?  Could it be defective media?
Can you reproduce it with another piece of media?

Bjorn

