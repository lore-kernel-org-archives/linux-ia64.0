From: Dan Kegel <dank@kegel.com>
Date: Fri, 06 Feb 2004 16:50:18 +0000
Subject: Re: gcc problems
Message-Id: <4023C5CA.3010405@kegel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton wrote:
> Andreas Schwab <schwab@suse.de> wrote:
> 
>>The fields were named differently in old versions of glibc, but the whole
>> layout didn't change in any way.
>>
>> -  unsigned long int sc_rsvd[16];/* reserved for future use */
>> +  unsigned long int sc_rbs_base;/* NULL or new base of sighandler's rbs */
>> +  unsigned long int sc_loadrs;	/* see description above */
>> +  unsigned long int sc_ar25;	/* cmp8xchg16 uses this */
>> +  unsigned long int sc_ar26;	/* rsvd for scratch use */
>> +  unsigned long int sc_rsvd[12];/* reserved for future use */
>>
>> > The easiest workaround is probably to install libunwind on your system
>>
>> The right fix is not to use a 2 years old glibc.
> 
> 
> That's not very old.  One shouldn't have to upgrade libc just to build gcc?

Did the two-year-old libc really support ia64 well?   I guess Itanium 1 was
out then, but those were early days...
- Dan


