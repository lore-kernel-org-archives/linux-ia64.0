From: Stephane Eranian <eranian@cello.hpl.hp.com>
Date: Thu, 27 Jul 2000 02:46:55 +0000
Subject: Re: [Linux-ia64] RTC config option doesn't work for IA64 ?
Message-Id: <marc-linux-ia64-105590678205234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205233@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205233@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> Is it just me, or does the RTC config option not generate a
> working kernel for the IA64 test4 kernel + david's 0714 patches?
> 
> It appears that at least a header file is missing, I don't know
> what goes in it as yet:  asm-ia64/mc146818rtc.h
> 
> Basically compilation fails if the config option is turned on.
> 
Normally you don't need to enable the CONFIG_RTC. You should enable
the CONFIG_EFI_RTC. Also in /dev you must have something like this:

crw-r--r--   1 root     root      10, 136 Apr  5 15:38 efirtc
lrwxrwxrwx   1 root     root            6 May  5 15:29 rtc -> efirtc

You can keep the legacy RTC under another name. With this in place,
the hwclock program should work seamlessly.

On the machines that we have, if I recall correctly, the legacy RTC is still
present but the code has never been tested. Anyway, DiG does not
guarantee the existence of such a timer. The only portable way is via EFI
runtime services.


-Stephane


