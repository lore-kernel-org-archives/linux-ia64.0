Received: from mout.web.de (mout.web.de [212.227.15.14])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B13DC2206BE;
	Fri, 21 Mar 2025 10:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.14
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1742554417; cv=none; b=SI/IsXXtfIvX5a2nqKriYj+V5cBZESPXb/vJgaGaVeVdMDSyFOsnnnFu5Sa0rBFIykRvq98/eu9ZvD/KEkliSTcqR6WonQ8gd6eVlDGONF6tcQcD2mEbGGlxrcX4ux0Ur932CVXcHj2BHj4JsR/dekW1EpXx4CAiFYQVoIWDnsI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1742554417; c=relaxed/simple;
	bh=AAb0Rqht8NtXcQ8HqvSZghQDhlfn2elQnUndnHkGw8o=;
	h=Message-ID:Date:MIME-Version:To:Cc:References:Subject:From:
	 In-Reply-To:Content-Type; b=GWKQJrzLvVQ6PgAytTpasE3tdGHES3jtRZ5R2byahsdAEKzOoTxf51vwVtRHvJ+69QYlfPU7jMBONtwnChrexk5l2t7y5xm+U4jc94b6pORv+ufK4bU+7s3eKhs08+0spX6ncw62SqCeEm2w/n5jg6LgoVVRd/VX4PQkjqEb06Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=K97B5S5B; arc=none smtp.client-ip=212.227.15.14
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="K97B5S5B"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1742554376; x=1743159176; i=frank.scheiner@web.de;
	bh=lj+ks7erNgDIgdRVjnC5pt2bxvom2mserscxEkZYLa4=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:To:Cc:References:
	 Subject:From:In-Reply-To:Content-Type:Content-Transfer-Encoding:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=K97B5S5BXSv5Ih4r6ioaV3lxtpwB1bu0OQnZaHSWyU+mj/sX6PW8GpDtT0kiG6WC
	 UksG/EkEfr0/Kxj5i3ewqgYp6F1Kl4NP93QojFUtneDdTHXW4Clm0Aqim7pLfrNKk
	 dX6o5SQwcYoEh9S1ry/zyFlKKH0zau8ogjaRSNp7zuPIUGOrQCPvbY95tK2Ox5Pmx
	 ofCiCfwqBaaTVF0AFyREG+07wTak3d6Jye1uZGSsOXHo3M4+gvgeExgfkV16jEBx+
	 k2o+dR9OvYrcLFnX6Mw8SVucTz0YHpCC0Jev9pj0pqOqaoHEVizhBzArZOFKZNNQh
	 h7RTUa91Rg2IoNr6gg==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.218.204]) by smtp.web.de (mrweb006
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MZB01-1ti5Un189h-00XrJt; Fri, 21
 Mar 2025 11:52:56 +0100
Message-ID: <9cafd34b-60b0-47d8-bfc8-1caa210bb20a@web.de>
Date: Fri, 21 Mar 2025 11:52:54 +0100
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: gregkh@linuxfoundation.org
Cc: akpm@linux-foundation.org, broonie@kernel.org, conor@kernel.org,
 f.fainelli@gmail.com, hargar@microsoft.com, jonathanh@nvidia.com,
 linux-kernel@vger.kernel.org, linux@roeck-us.net,
 lkft-triage@lists.linaro.org, patches@kernelci.org, patches@lists.linux.dev,
 pavel@denx.de, rwarsow@gmx.de, shuah@kernel.org, srw@sladewatkins.net,
 stable@vger.kernel.org, sudipm.mukherjee@gmail.com,
 torvalds@linux-foundation.org, linux-ia64@vger.kernel.org
References: <20250320165654.807128435@linuxfoundation.org>
Subject: Re: [PATCH 6.6 000/166] 6.6.84-rc2 review
Content-Language: en-US
From: Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20250320165654.807128435@linuxfoundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:FZOMuxYWfkGNPUx+egv2Is+x3xkGsYHfthlaElf7yQ6ILZTFjll
 m1CR2/m6A79XWR1FkXzoA5BI4UO68rFwQlhL645Q26Ci5NO3/yQMGHdx9YZ6/ZZVb7IfQJt
 CsN0tH8kM7TyBZgKUsZGH2UOXiLfRAL7tZ12AyMWLR4kGXExibRpGiWFcYO8hXrjwaTv81I
 t0yhHpTez1+MzG8r/LFZw==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:RBEAxNVhH8M=;GaZqruuE+5pIFIvaV7pKOvz8OFd
 StQ0iwX7b3KewJZOz7s9dJ9bnbXqIdVR1wLo/RKMbEwJSdvTCbBSd6WhlVASxX5IXZqGZFo6r
 9ivIVUYxaj9juaQw5OJT4NYjuUEnx8xWP8Qnv6PqN2LfjXmsgrzOMOB80GtVUBFLWKj5aXvrK
 CtOD6bWfjc2TKO47mBa5KXqKKeoPyJT0eO4fzDIQe0RDjuh1WkdHDYQej0Fu9m196A10Bo6vI
 yH0g2PNS7IMq0gS32LGHiNfCTD8GkXteRgicH+baYGjCfAh9vYgrkCzZzPNA8FTsrz64v09NC
 H8FSc6VDEvVSXeKhqp/vgb+YaYGVISXF5I7IKKFFhn8wU6uHp1+a6Nq+wQRLGbBcx24uu35Ns
 XsKH5cegroxMaiYx7vSQCGCD0PRGvYv5PFXClnXs3uKArrrA28d1is1DadcN8K3KTNdmOXvMI
 1JRIJ/Zj+vL2qYVtGfodvWBva67kuspSc9aqOwEiqVhq+jQ78Sy0f4RKzjpIS6BG4rTLMC5IS
 4DEluZkPAgr7AxvfoYG/fTdon2JE16+iRHC5UbFlS7HSvTVtkZhEt9ksOBSAaxKuPBR8QWUh4
 PHGZG+xwzDnCerFqzIPxYNviaDM9R0iZ2Z984pN/Kth8JIQuIblV/8dmrR4FvX+oxOwHY2xCG
 u4slgJqKUrx460TYK/mCL6jDXUEwVaehbtI/WIG8Qt2hAN7DzplgdDpkA80US4Hx8SlL3QxTi
 CAOoHTRAQn+HFRdT5QBJ4DvzQk1llGn5vMCfTTpM0St2yekuOs4f5MlvR3TfFGhqDrceplazY
 0/ovx7CNW3pkrji4oTEbUvjX1UpIH2x/DlqsqMYUXKc7nhxHttbwdWjQ1HKf1V+esgEnzTjVM
 LdZ21R4X7Jh9sMsPrhRWHN9z34eKzRTg6IEJz7uvioEAo4m4rpNe1rL27kh6/QQMDWWuthEnY
 G7MDyZ4OxzRhyYUpRxmyVeAGkPsuUUI52v3k/mKz9DEfNy6j2jvtTKLYaDbQue+bEIx7NtPbi
 jnmLimhgQiSxVmGh4wv4paI9pzdqXDXsFyFg/QG6wnD0ZBwg2qMy6VvQl3Jihxh1cnSuAFY0n
 gEx1ZnrHEHMK4bH27C8VycCRyqpgnve9MNvRhBNsoiK17hr/c3lQ+TAUQzGSCRm5PogMdJXhh
 V5g/Bbm1FowUjzIB66k8P1E6k91FYImGE0yl3vdQ7gWtrIBkg2u5wwsAHePkHk18gIf/3gpSy
 q8bL5Uqs3ROdieluuTV2u32cxR09CUtoxEhu0bfFF4sCzBFzBKVsJh2Nr8+HFBJwXtPCfRqVq
 KZj4BKcfAtc5yfpuXY7a/TY7HcHKf9iJUudNpqvjI50POP1fjUNliKzrnylbQkyVos3Pn3veI
 kYW9Bb2lBViNY+QschEUiUP6xd0w7PdtJad6mmyRYYxJz5BHEOp8YIVJ0rNWNNMQXxtUR0TXr
 Rkhu5a08XygD603TbmhpxNR9wwc98HmhSFUbPphU/IKKk26v8

> This is the start of the stable review cycle for the 6.6.84 release.
> There are 166 patches in this series, all will be posted as a response
> to this one.  If anyone has any issues with these being applied, please
> let me know.
>
> Responses should be made by Sat, 22 Mar 2025 16:56:28 +0000.
> Anything received after that time might be too late.
>
> The whole patch series can be found in one patch at:
> 	https://www.kernel.org/pub/linux/kernel/v6.x/stable-review/patch-6.6.84=
-rc2.gz
> or in the git tree and branch at:
> 	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.gi=
t linux-6.6.y
> and the diffstat can be found below.
>
> thanks,
>
> greg k-h

Cross-builds for ia64/hp-sim and runs fine in Ski ([1]).

[1]: https://github.com/linux-ia64/linux-stable-rc/actions/runs/1398396707=
8#summary-39154720796

Tested-by: Frank Scheiner <frank.scheiner@web.de>

Cheers,
Frank
