Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19484E7D0AB
	for <linux-ia64@archiver.kernel.org>; Thu, 21 Sep 2023 20:54:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232129AbjIUUyN (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 21 Sep 2023 16:54:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45854 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232168AbjIUUx7 (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 21 Sep 2023 16:53:59 -0400
Received: from mout.web.de (mout.web.de [217.72.192.78])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7A3E344A3
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 13:30:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de; s=s29768273;
 t=1695328233; x=1695933033; i=frank.scheiner@web.de;
 bh=uqexmd/8/WIuUgbE5S5knmgi50ue2ttB2Ok0/JhVhTo=;
 h=X-UI-Sender-Class:Date:To:Cc:From:Subject;
 b=XLW3MtcAVYCdRo0XoUjYAljCSykNHzxaGvqnhj3LCjqrC1YDQCARmBGX6LCt0+C53/D5KskHCZC
 Ql9oyIA2xAsSprtQTdFcrVWdTLFAmb683zzMwInpMMoJcm2MexorkVsNs1RCksZ3y16c5NDi5BcZ6
 c77ZlRcABoJC9kMUbVG5+rdZPDdctMAuIbtqdVkXCPNSln6I5H1lf9YVvlU66b4mifUnA8ojHSJpR
 CgyPU1XlxFaD/TKlwfMeJAVarsjD7zavpG9Qc+IRxqdm9pYeqhoMJnyGCKO5IYFWtNB+51HKZZ5GY
 XzsWpDxEhIFZgNvF5xboqVorEI7CNzsYb2wQ==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.221.18]) by smtp.web.de (mrweb105
 [213.165.67.124]) with ESMTPSA (Nemesis) id 1McZnj-1rFa761E5d-00cv2s; Thu, 21
 Sep 2023 12:14:37 +0200
Message-ID: <adc65a97-2479-8779-0e09-4ec2fe946cb2@web.de>
Date:   Thu, 21 Sep 2023 12:14:36 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
Content-Language: en-US
To:     linux-ia64@vger.kernel.org, rafael.j.wysocki@intel.com,
        michal.wilczynski@intel.com
Cc:     debian-ia64 <debian-ia64@lists.debian.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ard Biesheuvel <ardb@kernel.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
From:   Frank Scheiner <frank.scheiner@web.de>
Subject: Build regression since v6.6-rc1
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:/NN9h09uYIPy6adehyzyE8dZxdFKrfX7qndZ1xHqdeem/ydOqtJ
 YIiccC1v5PCAfN0s7b1vR3reQh5v4ssI4V5Y3/8s7HaKrslTfb5V59Rtj/GzpJ22J9PRdxq
 aY2PkLpBs+N/gvDkHkbh+Gzb2EWMX9G+g1tuFWBRyrU6GXqLfrJ9GxQcQSSP05ynvMs0YNk
 itnVEhHFCvxkBp1zn1wSw==
UI-OutboundReport: notjunk:1;M01:P0:+dc1m2QEjSw=;5lmA29UAAml6jlQ1/QIeDKv3krX
 rS9/cnNdr+arURhnHtRQVRJ1RfW8mLdH3reLJWtsLAE+4KDVpI1Rr1Wwv7wj8+yuMCLu4qH1h
 ZmxSQIrivUB0fur/uA1UYrIvBhveG1KcPNN1LjIW04RUA6WFCjmLRll7iWwKNdFqxkh210aNW
 n2ZIEoyVkzzjDkvOsHiyxdE54ToQSmbCsUsJ6W2arqo9g/upAwDfSZIN7yCvUwOIV1rSCeb54
 Pdinw870AHn1L3VIIRUYTeiPqXzQjXmS0lEkUumJhmgyGSCNlcmdPeU8scvdDk+E98S3rnQ4O
 4qH/A6XleFfCH+aeiZ8585HuIHLtyVwkLaANogZRVmF3emWubwG7CDeByqtodEIgWd9HPKrG6
 LQWe0vUEw/AmVFFD2NBU0OV5MrhgabwgtxpUkn5hPz0/pPQ5nF4NRWnwfQxdqRWcgvTysrCkE
 bzDJZaQPfTmuDxFdQYqtjh9SMdi2zdtdes0GTHw4V0kJQEeFxYmczRSKeBL6jsKSPrPOSMc3Q
 9NXbU0JjDX+aflEiDizSN7eIgDbXyeauCppDJ87j4Dv5vbW2fxZnA5fM62XFtPvvjiPOzsM04
 Un3kkT3OHtA0qur17+nLFLe6GS0OQ/BKMMalD7Qi2KZJF+fMA1UBIoqULp5KKUyJsmT2OdQkF
 imXH2Lgi5tZqd8wFpEOKo39nCb5jc/jcOUvY+aDUdfko1DokbrJd90U5Dx8C7q/NIxf5ecHxu
 qLLaIFFTPISZI5rQ8IjR9cPujfQ+GZucqtjOLpUTQLdL8/iMWoflMixPfvgR+tNiKqYauewhu
 GE9AmHX0qPDcGGlz3hG+BL2TMRbs/XOwwP3N78yDT+FNDe9uxT34RU1SkSZdaT9K70phIugMj
 9UJMHMe36y5fUeWg2AU+RI63ByXt0ZRX7nusVWE3vVUBkitwbBpsUAjnBzSRxE3sPGA0AY2xF
 GyiiEt7lYKgzpSMYRJrZRI8CgjU=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Dear all,

since v6.6-rc1 (actually introduced with [1], specific commit on [2])
the kernel build for ia64 fails like that:

```
Making kernel...
time make -j24
LOCALVERSION=3D"-0bb80ecc33a8fb5a682236443c1e740d5c917d1d-ia64" ARCH=3Dia6=
4
CROSS_COMPILE=3Dia64-linux- all
Mon Sep 11 06:24:43 PM CEST 2023
[...]
   LD [M]  net/sunrpc/sunrpc.ko
ia64-linux-ld: drivers/acpi/acpi_processor.o: in function
`acpi_early_processor_osc':
/usr/src/linux-on-ramdisk/torvalds-linux/drivers/acpi/acpi_processor.c:596=
:
undefined reference to `acpi_proc_quirk_mwait_check'
ia64-linux-ld: drivers/acpi/processor_pdc.o: in function
`acpi_early_processor_set_pdc':
/usr/src/linux-on-ramdisk/torvalds-linux/drivers/acpi/processor_pdc.c:113:
undefined reference to `acpi_proc_quirk_mwait_check'
make[2]: *** [scripts/Makefile.vmlinux:36: vmlinux] Error 1
make[1]: *** [/usr/src/linux-on-ramdisk/torvalds-linux/Makefile:1165:
vmlinux] Error 2
make: *** [Makefile:234: __sub-make] Error 2

real    3m25.286s
user    69m26.895s
sys    6m37.619s
2
```

[1]:
https://github.com/torvalds/linux/commit/9bd0c413b90c6517b4a2fbedb74f50df3=
421b50c

[2]: https://github.com/torvalds/linux/commit/0a0e2ea642f6

In short, the change introduced a function call ([3]) in effect for ia64
without providing an implementation for that function for ia64. There's
a discussion thread on [4] that also includes a patch ([5]) to "fix" the
problem but that one unfortunately wasn't included in [1] or [2]:

```
=2D--
  drivers/acpi/internal.h |   14 ++++----------
  1 file changed, 4 insertions(+), 10 deletions(-)

Index: linux-pm/drivers/acpi/internal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- linux-pm.orig/drivers/acpi/internal.h
+++ linux-pm/drivers/acpi/internal.h
@@ -148,8 +148,11 @@ int acpi_wakeup_device_init(void);
  #ifdef CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC
  void acpi_early_processor_control_setup(void);
  void acpi_early_processor_set_pdc(void);
-
+#ifdef CONFIG_X86
  void acpi_proc_quirk_mwait_check(void);
+#else
+static inline void acpi_proc_quirk_mwait_check(void) {}
+#endif
  bool processor_physically_present(acpi_handle handle);
  #else
  static inline void acpi_early_processor_control_setup(void) {}

```

For me this patch solves the build problem for v6.6-rc1 and -rc2.
There's also another patch available for that specific problem by Ard
([6]) but I haven't seen this one included either up until 42dc814 and I
also haven't tested this one.

Could one ([5]) or the other ([6]) please be included in v6.6 (or
earlier) to "fix" the build problem for ia64?

Cheers,
Frank


[3]:
https://github.com/torvalds/linux/commit/0a0e2ea642f6#diff-80c82874cec85e9=
c2facf52535b929ec62284c001ab081bfd1c1d164bf2a1d66R179

[4]:
https://lore.kernel.org/lkml/c7a05a44-c0be-46c2-a21d-b242524d482b@roeck-us=
.net/T/#u

[5]:
https://lore.kernel.org/lkml/CAJZ5v0hnNK4O_HyinvTp01YxXR7V4vzpMhf85yW9M2=
=3D52-O2Fg@mail.gmail.com/

[6]:
https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/commit/?id=
=3Da0334bf78b95532cec54f56b53e8ae1bfe7e1ca1
