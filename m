Received: from mout.web.de (mout.web.de [212.227.17.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2839425D8E1;
	Wed, 26 Feb 2025 22:29:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.17.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740608949; cv=none; b=IzXLeRod3lW/4gkskjOu7ETC9vXOrtIWrFOzTiQz0N64LaYsF5VC5PA8co5DKbBL0/Vp0Aaqm1wdOwPYtgiHvIjSkCz/uzTQXLa8Fgq9U1ghKBtlGTe+WJI1fhGTc4iK9eP2eQnDl7Yapxh/fbfvpGHKI7W4LEq9fZmbdzuYRhw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740608949; c=relaxed/simple;
	bh=EbxbCoPO3gifEVQZd/Bb2pSeoxgFSSRiRoVwtNkOz2c=;
	h=Message-ID:Date:MIME-Version:To:Cc:References:Subject:From:
	 In-Reply-To:Content-Type; b=WHkSWMxZ3HfWc2PJVwCTxJBrigCnOQa4x7LHxDZJHyi6XCamfjffnEgCStTyx68DlFox30MBt5soa9R1D764sRdwrdQerMU+2xoG3yl+K8Cp30kiWR9mrT4wlf5GOkTRyEYazQQMH+/eNglwej5N917lLBd/FUU+jWr8klafvSw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=HSJZq6M0; arc=none smtp.client-ip=212.227.17.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="HSJZq6M0"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1740608937; x=1741213737; i=frank.scheiner@web.de;
	bh=EbxbCoPO3gifEVQZd/Bb2pSeoxgFSSRiRoVwtNkOz2c=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:To:Cc:References:
	 Subject:From:In-Reply-To:Content-Type:Content-Transfer-Encoding:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=HSJZq6M0ZoRwepZB7hxDSQBPCQODVXF7C9/SmXkolsuOqKcmYj0OVHlUg8+JbwqG
	 QjI0r5DeZYrKNSbGvNGK1A7fgk6XYYNIFwrBleCHl8MUqONjStYDjDMFBUq4O2we/
	 0k3FqPffRJhkDzx/Yik07VYWpOx3RgMw8E/S0euJi3g7iYlsiK5pj6PnIWW6Di21F
	 jOLrIaLfUaNY1hjKE0w46KPkd0Tz6t0jVsZhtXK8zkoRgRG0fjTdJ53CSmjRl9FXb
	 js2NmZU14rTM/kPPSjUi34hPXqu3o3FCdK3Ypyh8h6tFkkgie4lq/uTpDwG10kuOy
	 C/tfrpTFgBnq/VdP3w==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([84.152.249.245]) by smtp.web.de (mrweb106
 [213.165.67.124]) with ESMTPSA (Nemesis) id 1MjxiM-1t37mD2WTo-00ZLQl; Wed, 26
 Feb 2025 23:28:57 +0100
Message-ID: <ee286bf3-efa5-46f1-8edd-cc689954a533@web.de>
Date: Wed, 26 Feb 2025 23:28:56 +0100
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?B?VG9tw6HFoSBHbG96YXI=?=
 <tglozar@gmail.com>, linux-ia64@vger.kernel.org
References: <CAHk-=wi9Aa_sgCjSncJ7odZX_f=v5WZwWm+GuwXmVy1O+wiBsw@mail.gmail.com>
Subject: Re: Linux 6.14-rc4
Content-Language: en-US
From: Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <CAHk-=wi9Aa_sgCjSncJ7odZX_f=v5WZwWm+GuwXmVy1O+wiBsw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:zdxllv0rZkQpaODpIhWTBjWiW5U5ArYZdJdcuE92STasKYe72hh
 G1VDb4Bl7xWJ4B6qXc74NqJY1GF25AUGBA2+byoc579atAqEaBdZB21uPu/5SYeY+/9lpMx
 8CmO5rXiXGkANyGQlv6MCpz798V90CTHeD7Zm9UjxkLxkzuamfwQ7rRUKA2giuUgxOPzJ2z
 GxZUskiDw7EroQGbfJSNA==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:K8BurCISCgc=;/xd2F4Rv5cmJgnMcXij9uv1Me/9
 LfvlSTKSK4URUvqSn4U8ipGnuvqDG5xh93fJBR3h29ShMw25W2Yk2fWdzOzfcocb1lmLYEbxP
 wH/LWPFEJJdkiaUxQEgHgjiOAqah+H/q1i3bovsqBFxi6N1W3iLZmj4Pr7TfEmMu4hBnclf46
 CYKLuiC2HA1v4Pew2Ce2gHgDwgnvKMhMY+om1HiXxDa3RvrJP4ourO4ORu/KmIQudNoV0ih4i
 ZqDeBRalEc8bjAZrVfzAydSEmHg6y40j8b4adAA3V5ZI/tftGN0sfnezUZTK9i0KknaO+HcwL
 BCitB5btvXNIPJelNeFhyxMQiYkuO5pGasbeL8bVlNQaoRMEInOTNSwEJftDKYEheznGTXQkt
 FWJNEdOY5MWUtmU0P3DaNDGHLADCQ2ndA+g5sF+VCG6sVwm/nyhetESC+t4FAjToXjpx4IfAM
 1VX/RDxnAHXPcr7NxQPemM7ASgNeKVvt6jB+1/HQFK03dIyBlaWvQYfgMRXj7O+65BiCBARvL
 gF5tZ8Lx/PdR2v7GcgKAJV8emej4laEvHdK1e38RraaqhBYEVK445pNqWBHDkHTnwWfLIjtJH
 amXlwDpfWFLdqZ3esmY5zSxAWAQkVENj7HALiF9qbWQ+dunOS7XD74ZqthCS8TSlCCGxPTu7r
 i1x8xYw77VQVyXAc4nApo8FSqKBVFwtiMzgqKj6PDhrFCaMXRX5Ke8PhF2QQ+7/cP0Zk/WGzM
 /2Lv+JU39EmYAPaaB8UumWdCgJFHblhq/LL+LcJ+MPhsK7v9g1CvdoAXuhw2ohbiTASQUE7Sv
 rKSirldQSW0KvaqWMc4ufS35Pd10+ZK/AUa8jigLqtA12t2z1ErJI1H1Qc3KP01Gg9MQjijSG
 3B8Ay3ROI5OncpV7wkfvhXHQQ2xOxHIEZL1iBh8VKezk+6gWDeIvD3ItkUzo5Yt4wpFWr4P4f
 GA/0qZnX6XcWApxoIH6mkO986xIIRV6Ejyxy1GDov9Jv8W6zxCPvw69kH5fxGk2n5+JvJykJM
 h4QhLKJHs5oTSgpOqvm7Q7JElzNaq2xsrSEmTwOIcVsMWrEkcsj87VbL0QXavIX7kqgjWq5nd
 tK5GLOURFWqco1nMWjp6rzAwFfxBnYJe7mhXNoYQDjmAroFOC0cR0nsofVRoBL5+hRVIhC+aE
 2/2KO7/bGWTvxfElfI/VScd8GupVCJ54wcJu8q/+D5DNMLvJJfqH1/s/1VnxQJX7pgnBZ7Dj5
 lswOwCZjp1I12iKcAjVpewBXE8EQpHvLKkMNHrw8GDQHx1dpKPqHcUBJoNLRFGBRYNPIYVn6w
 4JS4jVHwXvMUcJ7p7uLDJyKN+mK4U+6f5UMdsWbC9U3CcRULbA98Uu18QdCyt+p+nNB9kP9Cu
 +UshojNOUZzKq3X+EwSEzHcj0Fr6TRv0L9o1/Lxd3GPVdK7mpao62oVMBh

> This continues to be the right kind of "boring" release: nothing in
> particular stands out in rc4.

Yeah, also nothing special to report on ia64 for this RC. Apart from
we are still here, things are still working, etc.

> [...]
> So - knock wood - 6.14 looks to be on track, with everything looking goo=
d.
>
> Please keep testing,

Will do. Now also on a new test system: a BL860c - a nice little ia64
SBC ;-) that I finally put to work for our cause, thanks to the example
of a forerunner in our community.

As usual all details can be found on [1].

[1]: http://epic-linux.org/#!testing-effort/log.md

Cheers,
Frank
