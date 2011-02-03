From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Thu, 03 Feb 2011 21:10:34 +0000
Subject: RE: [RFC][PATCH] kmsg_dumper for NVRAM
Message-Id: <5C4C569E8A4B9B42A84A977CF070A35B2C147F4393@USINDEVS01.corp.hds.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1472ACC8@USINDEVS01.corp.hds.com>
 <20110201092942.GD21239@cr0.nay.redhat.com>
 <987664A83D2D224EAE907B061CE93D530194487CA2@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D530194487CA2@orsmsx505.amr.corp.intel.com>
To: "Luck, Tony" <tony.luck@intel.com>, =?utf-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "Yu, Fenghua" <fenghua.yu@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "arnd@arndb.de" <arnd@arndb.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "shiyer@redhat.com" <shiyer@redhat.com>, "pjones@redhat.com" <pjones@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

Hi Tony,

>I wonder whether you could use my pstore file system interface
>for this ... you'd need to write a backend that used EFI variable
>space to save the pieces of a console log, in much the same way
>that I used ERST to stash the pieces.
>
>This might be a bit messy - but I think that it would be
>worth doing in order to provide a single user interface
>to the kmsg_dump on different architectures, regardless
>of the underlying storage method used.

I will check whether I could use your pstore file system interface.
Could you please send your latest patch to me?

Seiji

>-----Original Message-----
>From: Luck, Tony [mailto:tony.luck@intel.com]
>Sent: Tuesday, February 01, 2011 2:47 PM
>To: Am������rico Wang; Seiji Aguchi
>Cc: rdunlap@xenotime.net; Yu, Fenghua; tglx@linutronix.de; mingo@redhat.com; hpa@zytor.com; x86@kernel.org;
>tj@kernel.org; akpm@linux-foundation.org; a.p.zijlstra@chello.nl; arnd@arndb.de; linux-doc@vger.kernel.org;
>linux-kernel@vger.kernel.org; linux-ia64@vger.kernel.org; dle-develop@lists.sourceforge.net; shiyer@redhat.com;
>pjones@redhat.com; Satoru Moriya
>Subject: RE: [RFC][PATCH] kmsg_dumper for NVRAM
>
>> This looks like what Tony wanted, pstore.
>
>Yes - this looks like another means to the same end (making console log
>Available after a crash).
>
>I wonder whether you could use my pstore file system interface
>for this ... you'd need to write a backend that used EFI variable
>space to save the pieces of a console log, in much the same way
>that I used ERST to stash the pieces.
>
>This might be a bit messy - but I think that it would be
>worth doing in order to provide a single user interface
>to the kmsg_dump on different architectures, regardless
>of the underlying storage method used.  I.e. the OS
>vendors would just have to write startup scripts to glean
>information from /dev/pstore and clear it by removing the
>files there. Rather than having one set of scripts that
>looks at EFI variables for machines that use that, a different
>set for machines that have the sparc64 method of saving in
>some special area of ram, and yet another set for a machine
>that has some other motherboard magical non volatile storage
>that hasn't been designed yet.
>
>-Tony

������������{.n���+���������������������+%���������������������������w������{.n���+������������{������&���������������������������}���������������z���&j:+v���������������������w������������2���������������������&���)���������a������������������z������z������������+���������������������j������w������f
