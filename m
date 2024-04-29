Received: from mail-lj1-f177.google.com (mail-lj1-f177.google.com [209.85.208.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07A9C15E85
	for <linux-ia64@vger.kernel.org>; Mon, 29 Apr 2024 15:36:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1714404999; cv=none; b=bs4AG2yDywPaHEMs7PovsHQ5ZLn/IsEltvjBcMrPeVr/Plv+Lg6xWNvzUiBxHAH9YX2HY2e/1HVQ7CwmYjMS4glhqykCfOCTBvlYP2TlBxsF0HcLPdArh2/uebqbINZJGfaU1pFEC5z4po2kRXxaHzu8QJW+xjAZ6QPz2B4KX1Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1714404999; c=relaxed/simple;
	bh=/MEHGX1x3HuvGrlg1scB17bYHXUuGpaIRKOiwd6rFkU=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=Xx+BoHbEt+5+20CgXzCcp8xDgMCHcCeuUMcrHA8JQ2aut3oJb59xQfCDBYB1d44CZ3xEsypCFpWytPTwY4gtF4B8Rg2aIwMP2OFmJ229h0qz3B4DH9F4XbJxmi+bLYbJI4YpCNRqk7hdEoPyOjvbp+mLQ+vZavAeximTWUfSZYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=d20OgCce; arc=none smtp.client-ip=209.85.208.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d20OgCce"
Received: by mail-lj1-f177.google.com with SMTP id 38308e7fff4ca-2e060d49f87so8917271fa.0
        for <linux-ia64@vger.kernel.org>; Mon, 29 Apr 2024 08:36:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1714404996; x=1715009796; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=/MEHGX1x3HuvGrlg1scB17bYHXUuGpaIRKOiwd6rFkU=;
        b=d20OgCcemU23BV3Napt/CmBusgdGCkXgwgCab04BRJlg85BUuIopaLEjXLsf5XBFTq
         7a4SD0+mgDdORu4Q/HSxZ7Y7m/lPPgJbDI1yDtNl8mckk81XR+/0q/wtuSlaFvS1A7Cl
         T/bPXhBi48CHtpsw8ELUuTcYUPWLbu96VaLEH9RrCyfD6nXCoKZQSVUdEX94S0Cb7ace
         0VROUkJOg7P9Laq4EeZQ0I6Gbg/X2IRPemSx3RCMAaLNTanUW6Y864LTIZ+jYSZA9N0j
         Fq35gayngRmQgcHuZ5MfGcHxZFJAsxmunAXPUFHq8ObHm/zcgb4UCBkhLWRDjaWOsoDc
         rIdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1714404996; x=1715009796;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=/MEHGX1x3HuvGrlg1scB17bYHXUuGpaIRKOiwd6rFkU=;
        b=qaq2SHTjNuLyI+x6ZhA/NGV4ATBy5b9QMumSBB6To5RhBfhxTYzdeTxAMkkNSUJJWg
         LD9tx1eD8owaVYVZfnLwyPlKetjAHKu/OtXXDxlbZ2I5NoI3Xtq7Gpvh+ikPUquWSYSU
         9gHIKbyGq2Qrh+iLXM6I1QViWl3x2EJHkLI0ZTXTGnZnVniHObKlLVVq8C13fLg1cFKi
         GWu6LQplBJj8VaGNWwg2xFU65MlDfEl8I29FVzDsOMUEU47fcnbVRyKzhRD7Xi3Nyt3u
         NDG+lfThWc6Sh7CQz4/4g83O9cGWQKwt06TDUVQLP8wcsNYB4fVKQwCZhPqdK+8H5Yrq
         X2OA==
X-Gm-Message-State: AOJu0YyYWnCNqXTKHgbfrybIeuXCN8yaj2ebrbNZgVXz2+ILxIRcSsfd
	3JfpJB+lZ8Um4Q+X9lHOcmoOIeUoVgNCAp7gdFKwQysB9HBQQeV9Mq6VCVvTd0R0d6CIYtYz7ls
	PkhYl5dTVNHetFj6U69+H8FxACW5J8Rir
X-Google-Smtp-Source: AGHT+IHHc1gTYWb6c2BqQePeU2BYnIxYUvD5I3QrOcvjkwMFcapSix0o4Sq86uGQHo5haF3iyKRqjts4cGh1P3mAWSo=
X-Received: by 2002:a05:651c:333:b0:2e0:bccc:80ae with SMTP id
 b19-20020a05651c033300b002e0bccc80aemr2920ljp.10.1714404995927; Mon, 29 Apr
 2024 08:36:35 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?= <tglozar@gmail.com>
Date: Mon, 29 Apr 2024 17:36:24 +0200
Message-ID: <CAHtyXDdy5Lub_UeMQRgr8O_G-XK0_XRD3J7wVB9t9rRD5x6d4g@mail.gmail.com>
Subject: [ANNOUNCE] Linux v6.9-rc6-epic1
To: linux-ia64@vger.kernel.org
Cc: Frank Scheiner <frank.scheiner@web.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello linux-ia64!

We are announcing the first release of the linux-ia64 patchset v6.9-rc6-epi=
c.

We have been maintaining an out-of-tree patch with Itanium support for
the Linux kernel since support was removed in November 2023 and
effective since Linux 6.7. After some time of successfully rebasing to
upstream master periodically, we have decided to adopt a model similar
to PREEMPT_RT and make formal releases for the patch, with the version
suffix -epic.

This is the first release of this format. At the same time, the
repository was also re-organized to mimic linux-rt: the master branch
is now master-epic, and future branches will be named linux-a.b.y-epic
(e.g. linux-6.9.y-epic).

Known issues:

- Kernel boot hangs when CONFIG_NR_CPUS is higher than 64.

Fixes (compared to 6.6-stable):

- Kernel now boots on rx6600 machines again after fixing a bug in the
mm subsystem.

The release may be obtained from GitHub:

https://github.com/linux-ia64/linux-ia64/tree/linux-6.9.y-epic
https://github.com/linux-ia64/linux-ia64/releases/download/v6.9-rc6-epic1/p=
atch-6.9-epic1.patch.gz

Tom=C3=A1=C5=A1 Glozar
