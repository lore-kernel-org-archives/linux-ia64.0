Received: from mail-pj1-f46.google.com (mail-pj1-f46.google.com [209.85.216.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBF2D80BEC
	for <linux-ia64@vger.kernel.org>; Sat, 16 Nov 2024 15:40:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731771634; cv=none; b=eeqAFhM3JmGRTS6eTKCzu8yDLEco6q7wsaYr/lZZ1f5dC/ALKKWbMGzVBcuMWAn+ugJjwOCgpKS3frx1E0deUsZKlRjde10BtoyEkuObj5Alh9EfYVKzf1gIqX4siGQPtbvVZOZk04FnKdFBBbclzReHyD6evMzOBkrr/CjeFPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731771634; c=relaxed/simple;
	bh=Wd+7kLQISUZlzyPvYmSUTVOb8NV4Vyd3OpsFXw6X7a0=;
	h=From:Message-ID:To:Subject:Date:MIME-Version:Content-Type; b=nmoDJoG4bChfwpLuV7ccx2c+OJ2o7I2m1VsYszYQJ9150qoOS2GQ7jfC+1D2raGgSDwvcoYVuvYentK0kpYFHWLHYaCoLsfJZXvaUtH6e5LpYdT74pT2tW0mZQcdYBvfaxkAIbUja3eR1MFDwvS6D24D9MmJD8/TToPeYh3uhTo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fWj0p+5p; arc=none smtp.client-ip=209.85.216.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fWj0p+5p"
Received: by mail-pj1-f46.google.com with SMTP id 98e67ed59e1d1-2ea45dac86eso217975a91.3
        for <linux-ia64@vger.kernel.org>; Sat, 16 Nov 2024 07:40:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731771631; x=1732376431; darn=vger.kernel.org;
        h=mime-version:date:subject:to:reply-to:message-id:from:from:to:cc
         :subject:date:message-id:reply-to;
        bh=XHEOkgJ64rwJ+cv0sVIqPUmbc8l+iTifR7HzGzNced0=;
        b=fWj0p+5phbcac8yPETfDAOtGGfSqGlRqz6mRQhYfP+69LoPHN311Fso+mazPH02wmH
         iflwVPVF13jCnYx9vVqwd6L02hHCyWDvW/8p2Zl2pb+E66YAanxoRBpZnLrdCw7wcGZA
         xBiEgaQQe+OQVtHl5QbkfrOjuLm5gT97R/G8iX0mOO6l3sMhGigx0sxeMAcHtRQEcPUq
         PTy1/JOBoJTKPxu2pCIY4YzcDu7ac2rALAhFWVyidrbpD3bO0nJSWqnhJdw6lriyfUxt
         M8aqjq0Pkbs91ehM9TuHHYUodq4yfoL+lSz+JxC1Vue2p1T7F4vm/MPCoU2vZf7GPXHU
         sgfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731771631; x=1732376431;
        h=mime-version:date:subject:to:reply-to:message-id:from
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=XHEOkgJ64rwJ+cv0sVIqPUmbc8l+iTifR7HzGzNced0=;
        b=tyJzscRjmZllYNC5Ts6NgmVFaY1NHD41z8DTJMhpYnyTIkzDmuCg2HC/rEluE4tBU7
         NO54nl3A0opu9D1Oh5oSu/uaDRzj30dYuqynRUvxiwHq/kTaj1nodJt1zwfxSQf9eSjp
         3xXyiyd723LAb+qXZwpeZaY3rXwuNcrfvnPOUJq0lydDXNMviM6ZO2cNSpS+84BatqZJ
         HtZq9pZxW/LnoODy7yjC0Hmajdq5d0KcR6X2X9TLc1/PzsFzF7hLhDI7EmB6vC5Din5j
         biG6OyHrs5M1E+Zv+alXlsX/2diQ/JPknSESo+PD6AsXhygd4EeWUfyY3IckMm9n1cpt
         SHTA==
X-Gm-Message-State: AOJu0YxTpQykm4lXCkd2jk8ucAaxCC9d9Qz3dLVDCzqFxFGi/kgpl9uq
	tFc5vRUHmoYKrcVOG3F2cK5/5VOeLFwgw3EUb/v4UWK+g5RB5BZHQAXWFA==
X-Google-Smtp-Source: AGHT+IHBFLX5XpCPZ0ExezsAOeUz6anUgaCk7CpzP1Z9f79vPiXYyMejyaW8tU0Y5DpuQ3GHSYW8cQ==
X-Received: by 2002:a17:90b:3bc5:b0:2ea:5083:6b6c with SMTP id 98e67ed59e1d1-2ea50836cf3mr497408a91.12.1731771631279;
        Sat, 16 Nov 2024 07:40:31 -0800 (PST)
Received: from [103.67.163.162] ([103.67.163.162])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-2ea0c1a918bsm4108175a91.22.2024.11.16.07.40.28
        for <linux-ia64@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Nov 2024 07:40:29 -0800 (PST)
From: "Van. HR" <carlonowell008@gmail.com>
X-Google-Original-From: "Van. HR" <infodesk@information.com>
Message-ID: <0adf78ff24f8074c89daac667ce89dbe09645c06f891952d48b407ebd2727246@mx.google.com>
Reply-To: dirofdptvancollin@gmail.com
To: linux-ia64@vger.kernel.org
Subject: Nov:16:24
Date: Sat, 16 Nov 2024 10:40:26 -0500
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii

Hello,
I am a private investment consultant representing the interest of a multinational  conglomerate that wishes to place funds into a trust management portfolio.

Please indicate your interest for additional information.

Regards,

Van Collin.

