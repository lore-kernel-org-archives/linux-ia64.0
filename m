From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2006 00:09:46 +0000
Subject: RE: [PATCH] registration for new system call unshare
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AA112A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
In-Reply-To: <1139440466.2535.2.camel@hobbes.atlanta.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> +#define __NR_ni_syscall			1294
>> +#define __NR_ni_syscall			1295
>>
>
>These should be __NR_sys_pselect and __NR_sys_ppoll otherwise you will
>get warnings...

I'm just going to put a /* 1294, 1295 reserved for pselect/ppoll */
comment there. (If anyone is looking for something to do, then take
a look at the TIF_RESTORE_SIGMASK changes that are a pre-requisite
for these two calls).

It's also time to bump up NR_syscalls.

-Tony
