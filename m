Received: from mout.web.de (mout.web.de [212.227.15.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03AC81624DD;
	Fri,  4 Apr 2025 20:08:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743797332; cv=none; b=UW6fHyqX/pXE2K6joevIP96p8wSAsV0rTH1t8c4RJdHhV7LQmQkzYwBmk1aQ9j38taRXiBLGWVyax05KhBAorSGPLJp55sY36Q4BWPOtLT0ZRixKIrNLLvUZJnvfB2SS4aDauNZg6Ix9m8brihywTbENkLjA0frqO69I4iYa6Ys=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743797332; c=relaxed/simple;
	bh=rFb8EIRrNetLyJcxwW5vp+VP4WYfMdX5pTix+iKkpLE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=GVtF8JojPijSJh1TYrfMJ7LKUEYi1fTkgItY54PsJeqqbUEPtL1JVawszijqqzUf4EEfyc7Uf/gZ6Fw48Q9rXu9n8Z2R1ggG9oYlQE+cDO7yO1KC1XfWyoIMEEhe1lhrAxqak+Dyih6nVxooIqXlXkgfy55Nk7OYU1x+MNmozeo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=ipWb3L9p; arc=none smtp.client-ip=212.227.15.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="ipWb3L9p"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1743797303; x=1744402103; i=frank.scheiner@web.de;
	bh=xrpxSLP1ycahFmgGkZ0VYLFyQeC1WzpMKJnrZUbVj+Q=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:Subject:To:Cc:
	 References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=ipWb3L9pxSxrTOduSEBGah68s18TJd52K1vmFICEcBIqOkEN0z3qVMm2XJzPjTnc
	 81HluNWqHVjB5Jw8q6h1A8aVNEiM0dfj4b9RPSsx9uIP7MXGcq2xB/LFYfak2PVNj
	 bhtk5v5F4MgovCfagFNoIQ6HGJtTh86VAIs74aocj9yn8yuZG1riDENa+KahJyOU0
	 9wHC4mjPoNA/7EFrWG1MuT/Mnx1aXiQEqsAC8kYk5XFZx4ukgXjWQ7iOmcmTE/7IT
	 UDI9loBhea8gOfvqVf4ZikVv8pK1n0GLWEWspZMhCHhSuMMD2QNg60wT43xXW4OI8
	 knwmdw8PxA+oYdDytw==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.211.78]) by smtp.web.de (mrweb006
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MYclj-1tWqH749EB-00Oeox; Fri, 04
 Apr 2025 22:08:23 +0200
Message-ID: <e452c6c5-a534-4547-8f23-c81ed65e52d2@web.de>
Date: Fri, 4 Apr 2025 22:08:21 +0200
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 6.14 00/21] 6.14.1-rc1 review
Content-Language: en-US
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org
Cc: patches@lists.linux.dev, linux-kernel@vger.kernel.org,
 torvalds@linux-foundation.org, akpm@linux-foundation.org,
 linux@roeck-us.net, shuah@kernel.org, patches@kernelci.org,
 lkft-triage@lists.linaro.org, pavel@denx.de, jonathanh@nvidia.com,
 f.fainelli@gmail.com, sudipm.mukherjee@gmail.com, srw@sladewatkins.net,
 rwarsow@gmx.de, conor@kernel.org, hargar@microsoft.com, broonie@kernel.org,
 linux-ia64@vger.kernel.org
References: <20250403151621.130541515@linuxfoundation.org>
From: Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20250403151621.130541515@linuxfoundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:fvU9h+f3+Mpevc/oYRGQnw02OPxuywenANdG2iHF5ka3nEeUn7L
 zxtB5jc77FkCt33nvcxEDPBSJlmus7WQI6pnVVVLafOcOi+VNoGMEJgw26hHiUet2N1yGUY
 cNs1e9RmHcBMG1orKuN6O1R1hCiXWSQ1ZJ3JttrZL14Y+tTdzmWBnD7615RWQkKJWWWgVHK
 3nub6kzJ/SskOFanbdIgA==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:4kYjNfGtMX8=;INUUeARrbEoqAc1aSuQoQ/pzR1j
 z+hnM14Rwow1+S3NLJdB2wbt3aJq338eqVlKW78IHX9v6XGpBLFK+8uNcxNvk6KD4/geOl67m
 w1TDFKxwksvZkCJ8xKM7UQ3nT3nSAkkJs/HZBaEkMnNK7dQTU2NHiYVjtMYtxrVPbD88fnTvQ
 MroEjdes7XyUzo1OtgJCqn8jUdvr6gqqKZwaKqRHp4KwVDlxFpALsr6slsjhsAfe8nV//9Zz+
 z8kHSJ5ffm+gG8WjXLkLMKLGT3YM+7zTxly7cL4hvM342QQlGFLk0BmmXyeNWPX09JxTxdyaC
 D0ly07e02piWACtp92cbg8yzSTb/W2taX2aeow61752i+zoKXb/z/Wj0/wVhMOR5d9re7Uo2y
 sSoNaVJqXwZBxRA7Kao6l5HsLMFqcX/FlTCEwmy+peNfNKyvKr/1q/gnEE0n/xHhwbh3h85/w
 rIgW8Z022VenIIaeTyx191hpFggWOqDk0GCzYiEcR+F8YxT0fGs2u9evaG9EksIGJmYfn947C
 HNxzGT5N1HAsCZj6IkgHgX51g9RhiWtw2jwm94AJ4gE0GbCO/7m7bQxt3yyXQC8znp5t8Sw7D
 nQsswtFZssdYqpmlyQXcB3rHAVruNwbeyZGb51+NxHbMXAfsiUoRyYHEP0GsiXc8K3vcHvDGb
 3zcRsM6HX8GqyvOisNUSUDUzwD2fp+xLBFJ9weBeOJ6hjqU0BM1WXtZvNH7PoFoHOvMawvdrj
 WEjTvXS2bv2WKe5Tetqi4B70L2J8nQ5X2nKGB91inj6ZqXfZHy1Zr9s4BnXAqRFWay3LyUmbr
 8PKgEKYa/EPJ/+ipkwDkJMy3eFASH9pMlrqQhU67RAT00oyOer9UMKH6ZGHYpn/faIjSN3K1P
 F9/FiPib4+hNYQRsoqe0PXlSogj7Jc4b9Wme0WQtvbJ7KBIOFZZg/VR/J3H9rEJ7LwuR9LgmA
 dAiiKNztZFon1Ir5msGKxIqxb5MScZVfkHU9senjk6TledMobZ6Ek9IuQg2Rnl0uychFYkoeL
 50UAMLpd1CkuRYLhDlih5uMFPwd15wvZAYfz+WWbff8lgwUJ/LWqbThyJykr2v9gju8RUQtMI
 BTLMTZbnYdYTenYy2On2lTfi7U50cMvK06mDsV6feU6AmwRu8CDtyVS4mTjcBFBeZT+gsOfEp
 XqfehW4sUGxOuqqOgxDndkNFK3JxU9AgL6RI9xNN6jra7RGMhmVeFErdLfV1VGpS+XX/EhUCC
 5SfF8pGBorM9rryPjd1PQE22Xzj8UT4dSi84ibW/SjElrAcF8ltr9a5I0m6kNGdMCa7s3Sj/9
 K54bUxbHxwmHF3A6fT4KvbY7ius6RG4R+Ty3C5JlD1dHjKb8oT6mT6nfwgClzvLCnOiVVgOGe
 TQ03U17zXqM71YXxl9bxRRZV1l8BMkNvZR7K1nicpl2C5NJ5khwKlEmGEe765/FZWqcGMFaxD
 xdD4Vjw9v5yzPu6U63b+0Db/vEjFRMh+ogaihY3fGs/sSf1yk

On 03.04.25 17:20, Greg Kroah-Hartman wrote:
> This is the start of the stable review cycle for the 6.14.1 release.
> There are 21 patches in this series, all will be posted as a response
> to this one.  If anyone has any issues with these being applied, please
> let me know.
>
> Responses should be made by Sat, 05 Apr 2025 15:16:11 +0000.
> Anything received after that time might be too late.
>
> The whole patch series can be found in one patch at:
> 	https://www.kernel.org/pub/linux/kernel/v6.x/stable-review/patch-6.14.1=
-rc1.gz
> or in the git tree and branch at:
> 	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.gi=
t linux-6.14.y
> and the diffstat can be found below.
>
> thanks,
>
> greg k-h

Cross-builds for ia64/hp-sim and runs fine in Ski ([1]).

[1]: https://github.com/linux-ia64/linux-stable-rc/actions/runs/1426331316=
2#summary-39980213570

Tested-by: Frank Scheiner <frank.scheiner@web.de>

Cheers,
Frank
