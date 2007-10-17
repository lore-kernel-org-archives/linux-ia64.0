From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 17 Oct 2007 06:32:40 +0000
Subject: Re: [PATCH 2/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4715AC88.8080502@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7ilnji9k.fsf@sykes.suse.de>
In-Reply-To: <je7ilnji9k.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you for quick comment.

Andreas Schwab wrote:
> Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> writes:
> 
>> Index: linux-2.6.23/include/asm-ia64/cputime.h
>> =================================>> --- linux-2.6.23.orig/include/asm-ia64/cputime.h
>> +++ linux-2.6.23/include/asm-ia64/cputime.h
>> @@ -1,6 +1,82 @@
>> +/*
>> + *  include/asm-ia64/cputime.h
> 
> Kill that line.  Instead describe the contents of the file.
> 
> Andreas.

Well, then I will follow powerpc's example, not s390's :-D

Thanks,
H.Seto
