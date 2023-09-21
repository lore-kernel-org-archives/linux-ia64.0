Return-Path: <linux-ia64-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4902E7D0A2
	for <linux-ia64@archiver.kernel.org>; Thu, 21 Sep 2023 19:37:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229606AbjIUThi (ORCPT <rfc822;linux-ia64@archiver.kernel.org>);
        Thu, 21 Sep 2023 15:37:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43724 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230018AbjIUThS (ORCPT
        <rfc822;linux-ia64@vger.kernel.org>); Thu, 21 Sep 2023 15:37:18 -0400
Received: from mout.web.de (mout.web.de [212.227.17.11])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 532E4EB474
        for <linux-ia64@vger.kernel.org>; Thu, 21 Sep 2023 12:10:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de; s=s29768273;
 t=1695323421; x=1695928221; i=frank.scheiner@web.de;
 bh=hgvKh8VZrdO3f35U01qaBwm/yh3eR4C0I948GxePHhY=;
 h=X-UI-Sender-Class:Date:Subject:To:Cc:References:From:In-Reply-To;
 b=KUODIfL/EQqq0vEPCX+bQubSxP8yfN3V46rrQ7fw+D9MlvIojPtVDjcdxw9ddTVgK9G3UE5XNO3
 zyRs68F1VJge0o1iOn1FVyanzRJDpLh4l/m/qTh8hinbWyyTbhyDuIFRUy5K/8vT4KYEMMeqr5eno
 91lqRNCq4VVGGbrmXGNElD6cdk7elNAnMk9Xpenn7xXeiPqxyZ0aF3kn2IxY+wChmO59y/Ed8Ya/p
 2tNCrJ6+ry8aArtcPlbsrlhSbraeZy5Bag0pyQHXzsTIEkjpFibqfraQAxZ9bR+S353dooxP1Qoyq
 Q5eLwspwiEYny/EYT7pU9qKpl0FHkHniasYQ==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.221.18]) by smtp.web.de (mrweb105
 [213.165.67.124]) with ESMTPSA (Nemesis) id 1MrOhx-1rVVbK37mJ-00oVpw; Thu, 21
 Sep 2023 14:07:37 +0200
Message-ID: <cc4e2861-32f6-e063-70ec-e47f88e8de14@web.de>
Date:   Thu, 21 Sep 2023 14:07:36 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.15.1
Subject: Re: Build regression since v6.6-rc1
Content-Language: en-US
To:     Ard Biesheuvel <ardb@kernel.org>
Cc:     linux-ia64@vger.kernel.org, rafael.j.wysocki@intel.com,
        michal.wilczynski@intel.com,
        debian-ia64 <debian-ia64@lists.debian.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>,
        Arnd Bergmann <arnd@arndb.de>
References: <adc65a97-2479-8779-0e09-4ec2fe946cb2@web.de>
 <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
From:   Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <CAMj1kXGDVWYJMHJay3j8P=EQMMv1cmSLRDoiDBrt1hdvZpOpww@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:QCuA3yAVK3FfHENFIskwUBDyJauoWY92tAZ/yL3DmC3lPjOOcxr
 PPhsDqdKTIk+eKIaDJBiCH/X9QWAEdd7hRGN+zT9KbCAtlQzbY05lulNCdJzIvGcDrzcKoD
 AIR1OcVlRDzQjNQ8yfjSVjaJ/J5v66N+oW3d3xgsQckG/5nQV5VUjqmG9pOnqsGRjfn67my
 43TPEOeDaiuiQNa7DwpCg==
UI-OutboundReport: notjunk:1;M01:P0:Mzrj09DpT1k=;igxF9JR0aQbASO7nmeaOFiRVmtu
 61GLdILBuKIwf3DlWVn1vcKzE5KY3hbM3nR4Y6xR9fTxZu+PQHukf1P16JXL591xsJIDNZ+Wj
 viFcFhZORlM6eXT6BMoEuTVq3OQCqcLx1/2OcLgtL3alHUc8/poSskWnKnYzpK+g3qeJnnE1a
 zy1L9gLes9/KAQ9o7rMvk2fjvOw/FS2OuwAGuAUIPORfL255wFfiKzdrDMdarIyspcvh9bdmv
 pvQ7zQwVIcgI3ZoTpb9yoTNwB3PLjhgiLOHKkNGC3UzXDr4PK+vM2HU6NN3fCG3J85SGVH5b8
 98FnPayadPFu37aEaOp8lyaGMpvYUcG4AWjfB5vEHitJ4HSXlD7DNGaTFzfbHaCnxVoUdxDtN
 87DIMR85CgOymRuA1R+DXqX069Wonkeh87y+s4t762nXNQKrvTWZru1/IkNPiizUtppB+qTok
 XYy6nqvFRHPrbCq9FHJICx6SvL8PC1Fvddn8s/m4UFsOI9Ar04xNev1p089xcR4zOgS9dvB+U
 uMXzRYMQu8Frkc/EJLIRGFyCNxWsktDUypk8onvtocntb0EpYF91uY/4Wu6yVuNtbkEpVgFqf
 uKhMADYZ2twx6nQGK9Lz62TdMZ78t+XZR8gHx3pJPH2EGSV8B6ZqQccDKO2mg+CDEBjYboMbt
 5PlYfFEM883iP7Q3FWwADrH1RWA1CGORdJKu/jN0QKi94bxr0v253IuOKidkZmGcnZrCYWBbB
 BWEQGAbfgSV+ZBsfcWMPK2ksU7czY9AZXq2ly3x86ljuw9P3/6Za5tfkOPcjV3iFcr8xdQ97A
 3t3mCWFh2g5b12v3AcnsQg7wOJCBqVjAy+MOKBJtLG7MxOF2WgHZNmdjXNGImtluALKm2x1C+
 6AErwHzJVYY/+X8BbmureKyLgfqElWLRLEoM/LrFqpoAl1IfoXWfwr6nq1ostvUuoTqf8wU23
 KEX68EmdpyWZe9KB7zZufTPgRWc=
Precedence: bulk
List-ID: <linux-ia64.vger.kernel.org>
X-Mailing-List: linux-ia64@vger.kernel.org

Hi Ard,

On 21.09.23 13:53, Ard Biesheuvel wrote:
> Hello Frank,
>
> On Thu, 21 Sept 2023 at 10:15, Frank Scheiner <frank.scheiner@web.de> wr=
ote:
>>
>> Dear all,
>>
>> since v6.6-rc1 (actually introduced with [1], specific commit on [2])
>> the kernel build for ia64 fails like that:
>>
>> ```
> ...
>>
>> Could one ([5]) or the other ([6]) please be included in v6.6 (or
>> earlier) to "fix" the build problem for ia64?
>>
>
> Do you mean by "fix" that the proposed fixes are just workarounds and
> not proper fixes?

Not really, or maybe a little... :-)

> I don't think that is the case - the function in
> question does nothing except apply a quirk for one specific x86
> platform.

...look, as I assumed and as you also say, the function is to "apply a
quirk for one specific x86 platform". So wouldn't it be better to make
that call only on x86 and leave ia64 untouched instead of putting a NOP
there?

I already wondered why no other architecture with ACPI failed to build?

Cheers,
Frank

>
> ...
>> [5]:
>> https://lore.kernel.org/lkml/CAJZ5v0hnNK4O_HyinvTp01YxXR7V4vzpMhf85yW9M=
2=3D52-O2Fg@mail.gmail.com/
>>
>> [6]:
>> https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/commit/?=
id=3Da0334bf78b95532cec54f56b53e8ae1bfe7e1ca1
>
> Either Arnd, Rafael or myself should send a PR to Linus to merge [6]
> as a fix, as it is already queued up in -next for v6.7.
>
> Or perhaps Linus doesn't mind grabbing it from here:
>
> ------------8<--------------
>
> The following changes since commit 0bb80ecc33a8fb5a682236443c1e740d5c917=
d1d:
>
>    Linux 6.6-rc1 (2023-09-10 16:28:41 -0700)
>
> are available in the Git repository at:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git
> tags/fix-ia64-build-for-v6.6
>
> for you to fetch changes up to a0334bf78b95532cec54f56b53e8ae1bfe7e1ca1:
>
>    acpi: Provide ia64 dummy implementation of
> acpi_proc_quirk_mwait_check() (2023-09-11 08:13:17 +0000)
>
> ----------------------------------------------------------------
> Build fix for Itanium/ia64:
>
> - provide dummy implementation of acpi_proc_quirk_mwait_check() which
>    was moved out of generic code into arch/x86, breaking the ia64 build
>
> ----------------------------------------------------------------
> Ard Biesheuvel (1):
>        acpi: Provide ia64 dummy implementation of acpi_proc_quirk_mwait_=
check()
>
>   arch/ia64/kernel/acpi.c | 4 ++++
>   1 file changed, 4 insertions(+)
