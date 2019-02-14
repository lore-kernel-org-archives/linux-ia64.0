From: Waiman Long <longman@redhat.com>
Date: Thu, 14 Feb 2019 18:35:22 +0000
Subject: Re: [PATCH v3 2/2] locking/rwsem: Optimize down_read_trylock()
Message-Id: <ffbd2cab-1cfd-334a-b462-2bd7986dc3b0@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------C468376F409BFB477E60571A"
List-Id: <linux-ia64.vger.kernel.org>
References: <1550089932-6888-1-git-send-email-longman@redhat.com>
 <1550089932-6888-3-git-send-email-longman@redhat.com>
 <20190214103333.GH32494@hirez.programming.kicks-ass.net>
 <20190214180239.GI2475@fuggles.cambridge.arm.com>
In-Reply-To: <20190214180239.GI2475@fuggles.cambridge.arm.com>
To: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

This is a multi-part message in MIME format.
--------------C468376F409BFB477E60571A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/14/2019 01:02 PM, Will Deacon wrote:
> On Thu, Feb 14, 2019 at 11:33:33AM +0100, Peter Zijlstra wrote:
>> On Wed, Feb 13, 2019 at 03:32:12PM -0500, Waiman Long wrote:
>>> Modify __down_read_trylock() to optimize for an unlocked rwsem and ma=
ke
>>> it generate slightly better code.
>>>
>>> Before this patch, down_read_trylock:
>>>
>>>    0x0000000000000000 <+0>:     callq  0x5 <down_read_trylock+5>
>>>    0x0000000000000005 <+5>:     jmp    0x18 <down_read_trylock+24>
>>>    0x0000000000000007 <+7>:     lea    0x1(%rdx),%rcx
>>>    0x000000000000000b <+11>:    mov    %rdx,%rax
>>>    0x000000000000000e <+14>:    lock cmpxchg %rcx,(%rdi)
>>>    0x0000000000000013 <+19>:    cmp    %rax,%rdx
>>>    0x0000000000000016 <+22>:    je     0x23 <down_read_trylock+35>
>>>    0x0000000000000018 <+24>:    mov    (%rdi),%rdx
>>>    0x000000000000001b <+27>:    test   %rdx,%rdx
>>>    0x000000000000001e <+30>:    jns    0x7 <down_read_trylock+7>
>>>    0x0000000000000020 <+32>:    xor    %eax,%eax
>>>    0x0000000000000022 <+34>:    retq
>>>    0x0000000000000023 <+35>:    mov    %gs:0x0,%rax
>>>    0x000000000000002c <+44>:    or     $0x3,%rax
>>>    0x0000000000000030 <+48>:    mov    %rax,0x20(%rdi)
>>>    0x0000000000000034 <+52>:    mov    $0x1,%eax
>>>    0x0000000000000039 <+57>:    retq
>>>
>>> After patch, down_read_trylock:
>>>
>>>    0x0000000000000000 <+0>:	callq  0x5 <down_read_trylock+5>
>>>    0x0000000000000005 <+5>:	xor    %eax,%eax
>>>    0x0000000000000007 <+7>:	lea    0x1(%rax),%rdx
>>>    0x000000000000000b <+11>:	lock cmpxchg %rdx,(%rdi)
>>>    0x0000000000000010 <+16>:	jne    0x29 <down_read_trylock+41>
>>>    0x0000000000000012 <+18>:	mov    %gs:0x0,%rax
>>>    0x000000000000001b <+27>:	or     $0x3,%rax
>>>    0x000000000000001f <+31>:	mov    %rax,0x20(%rdi)
>>>    0x0000000000000023 <+35>:	mov    $0x1,%eax
>>>    0x0000000000000028 <+40>:	retq
>>>    0x0000000000000029 <+41>:	test   %rax,%rax
>>>    0x000000000000002c <+44>:	jns    0x7 <down_read_trylock+7>
>>>    0x000000000000002e <+46>:	xor    %eax,%eax
>>>    0x0000000000000030 <+48>:	retq
>>>
>>> By using a rwsem microbenchmark, the down_read_trylock() rate (with a=

>>> load of 10 to lengthen the lock critical section) on a x86-64 system
>>> before and after the patch were:
>>>
>>>                  Before Patch    After Patch
>>>    # of Threads     rlock           rlock
>>>    ------------     -----           -----
>>>         1           14,496          14,716
>>>         2            8,644           8,453
>>> 	4            6,799           6,983
>>> 	8            5,664           7,190
>>>
>>> On a ARM64 system, the performance results were:
>>>
>>>                  Before Patch    After Patch
>>>    # of Threads     rlock           rlock
>>>    ------------     -----           -----
>>>         1           23,676          24,488
>>>         2            7,697           9,502
>>>         4            4,945           3,440
>>>         8            2,641           1,603
>> Urgh, yes LL/SC is the obvious exception that can actually do better
>> here :/
>>
>> Will, what say you?
> What machine were these numbers generated on and is it using LL/SC or L=
SE
> atomics for arm64? If you stick the microbenchmark somewhere, I can go =
play
> with a broader variety of h/w.
>
> Will

The machine is a 2-socket Cavium ThunderX2 99xx system with 64 cores and
256 threads. I was just using threads from the first socket for this
test. The microbenchmark that I used is attached. I used the command
"./run-locktest -ltryrwsem -r100 -i-10 -c10 -n<threads>" to generate the
locking rates.

The lscpu flags were:

fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics cpuid asimdrdm

Cheers,
Longman


--------------C468376F409BFB477E60571A
Content-Type: application/gzip;
 name="locktest.tar.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="locktest.tar.gz"

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
rvxFngDIAAA=
--------------C468376F409BFB477E60571A--
