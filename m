From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 27 Feb 2006 02:25:09 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <117E3EB5059E4E48ADFF2822933287A43B3068@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>-----Original Message-----
>>From: Luck, Tony
>>Sent: 2006=C4=EA2=D4=C225=C8=D5 4:25
>>To: Zhang, Yanmin
>>Cc: linux-ia64@vger.kernel.org; Zhang, Yanmin; Pallipadi, Venkatesh; Sidd=
ha, Suresh B
>>Subject: RE: Export cpu cache info by sysfs
>>
>>Looks much better.  Still a couple of questions:
>>
>>> Below new patch exports 8 attributes:
>>> 1) level
>>
>>The software developers manual calls the cache levels 1, 2, 3
>>but we report them as 0, 1, 2 (which is compatible with x86 versions
>>of these /sys files).  Is it better to match the docs, or other
>>architecture?
We definitely should follow manual. Most chapters of the manual say the cac=
he level from 1,
but the detailed explanation of pal call PAL_CACHE_INFO is from 0. I will c=
hange it to start from 1.


>>
>>2) type
>>For a combined cache x86 uses the string "Unified", you use
>>"Data/Instruction" ... again which is better?
"Unified" is better which also matches ia64 manual. I will change it to Uni=
fied.

Besides, I will delete attribute stride and CONFIG_SYSFS to simplify the pa=
tch again.

Thanks.

