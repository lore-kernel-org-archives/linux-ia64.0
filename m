Received: from mout.web.de (mout.web.de [212.227.17.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBA4C84E1C;
	Fri, 28 Mar 2025 20:14:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.17.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743192882; cv=none; b=XWvfWD8Tlxg8VESYmR/3tyoPLQhVWo5Nc4IQE5jcRWzdmmgyc8A5n1So5PTct/DYjiS10klk1o+io6S4+QwY5k9Dk9ezxIJpeZg+zin0RwhGvlDohVcsXt4+BdjBo7+0OSZqp0OQsSAFjcCpW4UgnpiFSebn5DwHNQLD6cLgEAE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743192882; c=relaxed/simple;
	bh=YPtdzJO5oUoFKA0xxSLhX0XNUIPxQzTlPvmDG2M4iVw=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=qmcKzc31ixWZ5aBsoUH28c/+dZjZ+AlO6zJPLdjawSTy6KOLk4r8Wmnvp4Bmc1IvAAPsKbu+jx1kvfrj4lxndyBhBl1HmK1JSK8ebyuawxaKyVe24XHXc09TGlQxXDIhMUMo4lCJSvP3N5cT57p/WhSFnKWAZZ29gEEvDmtLLLo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=AQRvdriq; arc=none smtp.client-ip=212.227.17.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="AQRvdriq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1743192866; x=1743797666; i=frank.scheiner@web.de;
	bh=nqWIo8/jSCRWunTJuSYGCdTz7gW8eNWtG2ieH1TGqXk=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:Subject:To:Cc:
	 References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=AQRvdriqUuF7KIdO9Ku6Eqp0Vl6law6VvqUZ1sTeCEbPLTtHltx1KgmI+jL/Y8mj
	 4QgiWr5hJ7fXJEP7yp/WYREVz5w8Iyy90A3+TSywsyFhZe+JRmTRNuP3ckJrrtWR2
	 vEkvxdyy1Iv5+ZCnqUDCd1Ag0hc3pGXkbDq9btm2GHHmpJLz9FoFUbWmorA1IFaFf
	 4/Pwm9SDyChmXDvoQ52yonGPF2KdR+umC/HhA3Vj9GUq72IxkICl55vkEoXyVdD0Z
	 FxyFdhpzunz2ht2WomWAuytJ98+cNQB9cDVlASM2rwH0Ds6HzvRCSfwVny4qB7yDZ
	 d8U83lGCMs4z5SYwaw==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([79.200.211.72]) by smtp.web.de (mrweb106
 [213.165.67.124]) with ESMTPSA (Nemesis) id 1MPKB5-1tlyyi3Wvd-00PPSl; Fri, 28
 Mar 2025 21:14:25 +0100
Message-ID: <0ab0c4f4-c758-4366-a414-c8da5119c1ab@web.de>
Date: Fri, 28 Mar 2025 21:14:23 +0100
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 6.1 000/197] 6.1.132-rc3 review
Content-Language: en-US
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org
Cc: patches@lists.linux.dev, linux-kernel@vger.kernel.org,
 torvalds@linux-foundation.org, akpm@linux-foundation.org,
 linux@roeck-us.net, shuah@kernel.org, patches@kernelci.org,
 lkft-triage@lists.linaro.org, pavel@denx.de, jonathanh@nvidia.com,
 f.fainelli@gmail.com, sudipm.mukherjee@gmail.com, srw@sladewatkins.net,
 rwarsow@gmx.de, conor@kernel.org, hargar@microsoft.com, broonie@kernel.org,
 linux-ia64@vger.kernel.org
References: <20250328074420.301061796@linuxfoundation.org>
From: Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20250328074420.301061796@linuxfoundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:0C/7j4laSJiQHPFO1ub85Z6BCJyRBDuTFkXvVB+dSQ1pEncWXJi
 zZShf3xrW4bMxqQdvzLpE3g7SFK8VvJJ9KM/9l1lvjre64o4yc65inpOyUvCnLj0t85AmjV
 kl/0ZKjueQdZt+a7cGQa/C5mLCaUDEmk5wEmwcwqU+NaZo+W/8rguxJwn3JvP+STal0EnUc
 YgShNV7PsMHyHsOFPTDDg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:MCNclTEh+/E=;7QvyE0r7d0JI8HkQDGvTPH11JY1
 5kvlAQFtR7B1jc9qGY22g75foXnnCeqCIKvf6h4Dv1hehDEIQd3Wn0yY9jAUwUeCsF5PqW/K/
 wh7HaWGSn747CWx3YpCjkfaW6ITcNzOxKL9EjDMleuZ2XJhUQqNXpSLjNhC0hIMJR9f1Y+EMk
 OFLt61GYwilEQNBWeqXHQwsT25QWy6NiYEkd7UBP9DqeaCQNkwY7NaS5L7CEE88W2sae7/was
 PKdkkCb7D0HbMoq7NZbfHczqhk8XAblYaavHhdM/838+1dpSyGkjTFCLlbtEn/KM3yj92qF09
 qw9n6mVFEMWSFtXp9esHXYip5mJN3GYxWBeEyC0X1J0g9Epa3Ik/sGKLVfOd8PMISCaZQJh90
 aaV2t5M5HYMWafRASBZ+EQrZHwcIVUe0mnNs71rFYX56bEVEYPamH24E6YEVsohmoWU6wzxSH
 NcB8rkUoMtrhlo/3bZVTWePL66b/tElaMz1qHQGx+xFH2AO2T4p/SYbxLzVcbZp+BMLUnRsKH
 JExfP4WIBdvHDAR/47X+2dzIfNfOzsMik40RolpreU53wYRVvp0ICLnzPdE2crtK7l3wUqRzr
 a2Eb7alf3aBEIK2wz4dStWGw55tQvVuzi88mB3TnqfrmXACjdK0hTLPM+0InAMaJn9U7n3bKE
 ZZC3QRV1KPPuUqyOB69WdNl5Fx+l1pf9D9YX9slH2+AVUqSMkhFOjIZrxonTowajQeg5TuFFp
 rQIz3//W+SU5fFv5WobnybVb355HTSiAH2VuUWN4WoUdAbDbWamEZ3CbKpPCoVh+nyWsvwFbq
 AfBQujiH0kCchyMXvjOtL34P7cnPK3V3S+xPh8OClVKx3XK1xpAB2B+ePu1PzLEcimlqMfiM+
 Nn/SYQpLyuTnzcC1mHlAppvI2xHbfEfMFPbvlJzUv5dio1lxYyNlrnStMbebfTZOYxsBDExRk
 eKtjbdLt4e2CpMj6eAvY7tbwFyyK04k1VmXYSzFHxtJY58ljxkPTkUIn36hLd6VJPsz4wNqys
 2wE7aewVGOsz8HofhkEKStA8P4qddZft7gpRKF8SzrnQtzHdo5KRNXHsailwEqVGidqs6MT9M
 7jukE5ARiuKODkhlLbBmOTqz6n2R1ZVXp/ayqjWti1e0iNpqvlOcN5nD8p4QoTm6WccXoQmom
 UsC1T8wGhRX/gqZRPF4pnsCGPfOqp06I7IJNKHpRg9FaowuCie3pHBlZPaDaxup1jE14DZeIr
 Q8V24U31/v49a9jwZ6SvzSI2dWwLgXyYxaI5Yenk98TvomTKmVdbmxh3ZbYXE0txnE6kR8yyr
 ukoh8eHpPM/gTSnEG5ou518WHh+4fYs5waviTugjNR1Sq9QRvqjrZCi0hBYlUcG1/Oog+8aEx
 FzUYQO/vEny/bEXJb8gvLfHgR6OhIW4eddgvc6f2BSdgRwrunSfWTueSpl5GyS58rzCf50VPq
 SYXyyBCAkz7OUI3vkQsM3iu1D7Sy4tgqWhHGlAMJ78y1c5KGm

On 28.03.25 08:47, Greg Kroah-Hartman wrote:
> This is the start of the stable review cycle for the 6.1.132 release.
> There are 197 patches in this series, all will be posted as a response
> to this one.  If anyone has any issues with these being applied, please
> let me know.
>
> Responses should be made by Sun, 30 Mar 2025 07:43:56 +0000.
> Anything received after that time might be too late.
>
> The whole patch series can be found in one patch at:
> 	https://www.kernel.org/pub/linux/kernel/v6.x/stable-review/patch-6.1.13=
2-rc3.gz
> or in the git tree and branch at:
> 	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.gi=
t linux-6.1.y
> and the diffstat can be found below.
>
> thanks,
>
> greg k-h

Cross-builds for ia64/hp-sim and runs fine in Ski ([1]).

[1]: https://github.com/linux-ia64/linux-stable-rc/actions/runs/1412943352=
0#summary-39586577131

Tested-by: Frank Scheiner <frank.scheiner@web.de>

Cheers,
Frank
