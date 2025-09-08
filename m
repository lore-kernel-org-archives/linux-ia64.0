Received: from mail-yb1-f178.google.com (mail-yb1-f178.google.com [209.85.219.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8583B20C001
	for <linux-ia64@vger.kernel.org>; Mon,  8 Sep 2025 21:24:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757366677; cv=none; b=siaNlAQB44Oo6G4v6gAz7e9/aRUvx1ldrBOG7MimbULVtu9DHZOWBawKUf7F7BamVDadc+NHlugP9ZsGhBiGWE7YzFkQhWLKalaUlcfGAdvz0uOUTDe0FnnISKpmwNisT9frdkgPKZvvlMUECqMoobLI/JzpjWGlNolfDp3+TDc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757366677; c=relaxed/simple;
	bh=MkGEfeXPcmLX1hVuxSY9NPc6nmq1i9+sy+AgfyPmxeQ=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=MS+qXuPKkMLBS+YZX/Caq64D7QOddkgJiJzTR0HYLvse6NvjWtoyV2VdoLYevQEA4D+HDdfuxBdSXAgTmWuHYLKyliQ8kszabRU6Y/LYZ4DrxXadw6AHt0vpUxlY+9pjmaCBujUrgxDzMBPxR9dwZvveNnHhPqx/ygz56PZIfPU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HzFSF87J; arc=none smtp.client-ip=209.85.219.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HzFSF87J"
Received: by mail-yb1-f178.google.com with SMTP id 3f1490d57ef6-ea0150ee46dso1634278276.1
        for <linux-ia64@vger.kernel.org>; Mon, 08 Sep 2025 14:24:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1757366674; x=1757971474; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=MkGEfeXPcmLX1hVuxSY9NPc6nmq1i9+sy+AgfyPmxeQ=;
        b=HzFSF87JEjjqfLflgadePHi+yZh7OR0i4TvgVONdQmkWROBhkosoTBL96CwSDj7GBE
         8xHfwuwZjYmZClk8jJHt0Gp8FsrXZdDaR6TxPtgvlr1RiCCLWVwAHCWuOOfcWyh55o0c
         qcVK+yFN07pzWesNssgW+MfV3rMKj3OBnBG80X7TLY1IA5dHmeLUy1jScbQ5Z6tfjJ8s
         HEpTcWPI9Ssyq2kuAgjlWaa+Ct4itjbwF792pPi16rjVpUE4f+1yK2/JLZVjIUHriirG
         0reyE7JiQZDAK7XtMzCNmAW5Qh3UkM7cyOTXAsFy23vyRkCJ4E8FXRHyb0PjtEpsZcGT
         NRBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1757366674; x=1757971474;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=MkGEfeXPcmLX1hVuxSY9NPc6nmq1i9+sy+AgfyPmxeQ=;
        b=sxZLYS4RzLnFm87AbEYrIpcNKGj3CLD6FeY4h7LLj+gmDAhDmI1ZSfsw92WnKD6EAD
         teM7gBshyM7a0vy/CSdoK2giKKTEcfRPzkTNDFjoIRTE3MlCvwl6eUXgv7c8a23nkdkA
         k74S9RQGWVQH+z/3afgfoxxfiurc4xraoXr/H4sVG8d9MxSRBrMtnUaX7nPa0YC2Guun
         FpraUONzdQ6rW+vfcG+qvfrjv6Y3Wt6D1DPAX7aoS1LYS4pQHuB8Mcy7n0BZ+O34T8Qq
         0RoexAVj9xT1h85nxpe9bXnuWqAOJI07mqcMui6Tm3OrFbLyh/DqiYoij5IPTnx4RPU0
         ty3g==
X-Gm-Message-State: AOJu0Yy9otTiLyLAvgiIe1nL65HmYanEoCgf0LZET71IrhVrnV7l8BOY
	2Rw3kyv7GKdDQnfXFKY26IG8l/eKrTsrmwKig+nvuhMDnyF7RHTfzZFHaYJDizaB4He0YicycAM
	Z8xRAILLrshvPeA5tbiIurtXRwdtJIWm21Q31Y9o=
X-Gm-Gg: ASbGnctf3IHBw8mBLL+xqusWwAXnmY31qSfZNq089x7+jFm7V93KL4HPIfKTS3sWDa+
	0bIHGap9z6YCaGd6x5X/+7wd16BIohSD72EQ4ZKCoW0iqV3v0VXVQ9b+czrvSv/RAEyBg3tmaUE
	2YAZoyr5e1gz1M+5rLqsMv00GJCQfkRTGg1momQ0fPdDqJcXTKxg6b3muOJbyS1jxlt777c5tCq
	GzfZY7coaFVuVQwiX1NPzyqBDFEwmYvr5stC54fYgokmB+8VQ==
X-Google-Smtp-Source: AGHT+IFUt8UpsvpZEL7JqInfgP/oRjE9Z14h7btKqBmXWM8KrPwbzkTvmPwxnebuYOQk1k6NgWKFsaIzwwgz/gFmmd4=
X-Received: by 2002:a05:690c:490a:b0:71f:b944:103f with SMTP id
 00721157ae682-727f5541763mr94996177b3.48.1757366674222; Mon, 08 Sep 2025
 14:24:34 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?= <tglozar@gmail.com>
Date: Mon, 8 Sep 2025 23:24:23 +0200
X-Gm-Features: AS18NWDLUFBD-PFynAajrcCVk5XeFBrDZ8_gZqcXgEC_f34QNvf6IWdHAxtOql4
Message-ID: <CAHtyXDernSaNUtXas_nO+VR8NiBghoJgn=bfcta7fGpJDOiVOg@mail.gmail.com>
Subject: [ANNOUNCE] Linux v6.16-epic1
To: linux-ia64@vger.kernel.org
Cc: Frank Scheiner <frank.scheiner@web.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello linux-ia64!

It's time to bump up the version, and get the EPIC code up to date
with latest upstream! Of course, reverts of some bits and pieces of
code that is needed by Itanium still have to be done, but they are
sparse at this point, and the process is mostly painless: four whole
upstream versions were successfully merged over an extended weekend,
with some minimal help from parallel johnny-mnemonic fork.

With this release, a new commit model is adopted: upstream is merged
into the fork at relevant tags. This allows to push normally into the
master-epic branch, and track which linux-ia64 patches were applied
after the merge of which upstream release. New branches will no longer
be created for upstream releases.

Known issues:

- See https://github.com/linux-ia64/linux-ia64/issues

Fixes:

- None

Some changes in tools/ and scripts/ had Itanium-specific code removed.
This is not addressed yet in this release. Also, unimplemented
syscalls are piling up, so it's nearly time for to make that up to
date.

As always, the release can be obtained in patch or whole source code
from our repo, at:
https://github.com/linux-ia64/linux-ia64/releases/tag/v6.16-epic1

Tom=C3=A1=C5=A1
