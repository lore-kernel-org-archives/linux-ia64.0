From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Wed, 23 Nov 2005 02:52:55 +0000
Subject: RE: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD802C069E2@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
In-Reply-To: <571ACEFD467F7749BC50E0A98C17CDD802C069CF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Xen Mailing List <xen-devel@lists.xensource.com>, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, linux-ia64@vger.kernel.org

>From: Luck, Tony
>Sent: 2005=C4=EA11=D4=C223=C8=D5 0:11
>This comment:
>>   /*
>>    * The "aligned" directive can only _increase_ alignment, so this is
>>    * safe and provides an easy way to avoid wasting space on a
>>    * uni-processor:
>>    */
>suggests that we only expected SMP_CACHE_BYTES to be used in "aligned"
>directives, where having a smaller value than the actual alignment
>requirement of some object would simply be ignored by the compiler.

Understand. ;-)

>
>How much is this trick saving us?  Static size of data area in
>vmlinux doesn't change very much as SMP_CACHE_BYTES is varied:
>
>   text    data     bss     dec     hex filename
>8677481 1139704 1206357 11023542         a834b6 vmlinux-8
>8677417 1141808 1206397 11025622         a83cd6 vmlinux-16
>8677417 1146000 1206477 11029894         a84d86 vmlinux-32
>8677353 1146256 1206573 11030182         a84ea6 vmlinux-64
>8677353 1163152 1207085 11047590         a892a6 vmlinux-128
>
>I'm not sure how to evaluate dynamic behavior (allocation of
>structures whose size is dependent on SMP_CACHE_BYTES at
>runtime).
>
>-Tony
>-

So maybe we can simply remove the UP specific size definition and give both=
 cases to actual cache line size.

Thanks,
Kevin
