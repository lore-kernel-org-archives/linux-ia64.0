From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Tue, 27 Dec 2005 10:22:48 +0000
Subject: RE: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <8126E4F969BA254AB43EA03C59F44E84044DEE70@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051220180929.B19129@unix-os.sc.intel.com>
In-Reply-To: <20051220180929.B19129@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Greg KH <greg@kroah.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

>>-----Original Message-----
>>From: Greg KH [mailto:greg@kroah.com]
>>Sent: 2005=C4=EA12=D4=C227=C8=D5 13:35
>>To: Zhang, Yanmin
>>Cc: Yanmin Zhang; linux-kernel@vger.kernel.org; discuss@x86-64.org; linux=
-ia64@vger.kernel.org; Siddha, Suresh B; Shah, Rajesh;
>>Pallipadi, Venkatesh
>>Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
>>
>>> Sorry. My previous explanation is confusing. It's a link warning on
>>> ia64. On ia64, the kernel vmlinux doesn't include section .exit.text,
>>> so ld will report a link warning when a function is in section
>>> .exit.text and another function (not in .exit.text) calls the first
>>> one. When CONFIG_HOTPLUG_CPU=3Dn, function topology_remove_dev is in
>>> section .exit.text, but its caller topology_remove_dev is not in
>>> .exit.text.
>>>
>>> i386 and x86_64 kernel vmlinux does include .exit.text and discard it
>>> only when running, so there is no such warning on i386/x86_64.
>>>
>>> There is no other better approach to get rid of the warning unless we
>>> change arch/ia64/kernel/vmlinux.lds.S to keep all .exit.text in kernel
>>> image.
>>
>>Or just move that function to not be __exit, as you are calling it from
>>an __init function.  That would be the best solution.

I will change topology_remove_dev's attribute from __cpuexit to __cpuinit, =
and the problem will be resolved thoroughly.

Thanks.
