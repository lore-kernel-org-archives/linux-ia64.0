From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 01 Aug 2000 00:49:20 +0000
Subject: Re: [Linux-ia64] integer -> pointer question
Message-Id: <marc-linux-ia64-105590678205260@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Michael" = Michael Madore <mmadore@turbolinux.com> writes:

>> Hi Michael
>> 
>> Storing integers in void pointers without a cast is simply broken
>> and nobody should do that or to be more precise you cannot expect
>> void * to be the same size as int.
>> 
>> Basically the correct solution is to LART the programmer of the bad
>> code.
>> 
>> Jes

Michael> The code does perform the cast, but since the upper four
Michael> bytes of the pointer will be meaningless, it's spits out a
Michael> warning.

Good point, what they really should be doing is to use long instead of
void * then - you know that long = sizeof(void *) but you shouldn't
get the error for that.

Jes


