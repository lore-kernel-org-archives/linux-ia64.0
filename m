From: Robin Holt <holt@sgi.com>
Date: Thu, 21 Aug 2008 21:54:26 +0000
Subject: Re: kernel unaligned accesses on IA64 in IDE
Message-Id: <20080821215426.GD8051@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080819225606.GB22088@us.ibm.com> <20080820143531.GA6488@sgi.com> <20080821213146.GK11729@us.ibm.com>
In-Reply-To: <20080821213146.GK11729@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, tony.luck@intel.com, bzolnier@gmail.com, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org

> [   32.597792] outsl(496, e000000644678466, 3)
                            ^^^^^^^^^^^^^^^^

This is expected to be an unsigned int * and typecast to that in outsl.
Looks like the buffer being passed in is not properly aligned.  Time to
go look at the caller.  Make sure buf is defined as an array of at least
int size.  That should make this aligned on a 4 byte boundary instead of
the 2 byte boundary it is on now.

You can cheat at finding the callers by putting
	WARN_ON(buf & 0x3);
	printk...

Good Luck,
Robin
