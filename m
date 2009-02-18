From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 18 Feb 2009 21:35:02 +0000
Subject: Re: [PATCH] qla2x: fix printk format warnings
Message-Id: <499C7F06.8020407@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090218131120.d1beb9f7.randy.dunlap@oracle.com>	<20090218212249.GL16841@parisc-linux.org> <20090218133033.df24dfd3.akpm@linux-foundation.org>
In-Reply-To: <20090218133033.df24dfd3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, randy.dunlap@oracle.com, linux-scsi@vger.kernel.org, James.Bottomley@HansenPartnership.com, linux-driver@qlogic.com, linux-ia64@vger.kernel.org

Andrew Morton wrote:
> On Wed, 18 Feb 2009 14:22:50 -0700
> Matthew Wilcox <matthew@wil.cx> wrote:
> 
>> On Wed, Feb 18, 2009 at 01:11:20PM -0800, Randy Dunlap wrote:
>>> drivers/scsi/qla2xxx/qla_sup.c:915: warning: long long unsigned int format, u64 arg (arg 5)
>> I thought we were going to fix all these by making u64 an unsigned long
>> long on all 64-bit architectures?  I know benh is working on it for
>> powerpc, and I sent a patch to do it for ia64.  Don't think Tony's
>> merged it yet ...
> 
> Yes, we should do this.  But momentum seems to have faded again.

OK.  I can help with that then.

-- 
~Randy
