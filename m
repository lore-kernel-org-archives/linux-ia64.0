From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 18:38:03 +0000
Subject: Re: [PATCH 05/11] x86, mpx: add MPX to disaabled features
Message-Id: <54664C0B.6070604@sr71.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141114151816.F56A3072@viggo.jf.intel.com> <20141114151823.B358EAD2@viggo.jf.intel.com> <5466425D.1060100@cogentembedded.com>
In-Reply-To: <5466425D.1060100@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On 11/14/2014 09:56 AM, Sergei Shtylyov wrote:
>>   #define DISABLED_MASK6    0
>>   #define DISABLED_MASK7    0
>>   #define DISABLED_MASK8    0
>> -#define DISABLED_MASK9    0
>> +#define DISABLED_MASK9    (DISABLE_MPX)
> 
>    These parens are not really needed. Sorry to be a PITA and not saying
> this before.

One goal of the disabled features patch was to maintain parity with
required-features.h.  It declares things this way:

> #define REQUIRED_MASK3  (NEED_NOPL)
> #define REQUIRED_MASK4  (NEED_MOVBE)

So, no, those aren't strictly needed, but there is precedent for them
and they do no harm.  I think I'll leave them as-is.
