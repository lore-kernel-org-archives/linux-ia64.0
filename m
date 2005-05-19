From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 19 May 2005 13:33:32 +0000
Subject: Re: ZX1 address ranges
Message-Id: <20050519133332.GC6857@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050519130609.23006.qmail@web54006.mail.yahoo.com>
In-Reply-To: <20050519130609.23006.qmail@web54006.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 19, 2005 at 06:06:09AM -0700, Mohit Katiyar wrote:
> Hi everyone!!
> One more query .I am using ZX1 mio (HP machine)chip 
> If I have ram of very large size that is around 512 Gb
> then may I know where does the 261 GB is mapped on
> physical address space and the rest of division upto
> 512 Gb ram. 

You don't.  The zx1 chipset only supports 256GB max.  If you need more
ram, you have to use the sx1000 chipset.  FWIW, the largest memory
configurations you can buy for machines with the zx1 chipset are 128GB
in an rx4640 (32 slots * 4GB DIMMs) and 96GB in an rx5670 (48 slots *
2GB DIMMs).  4GB DIMMs were never certified in an rx5670, so you can't
put together a 192GB machine.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
