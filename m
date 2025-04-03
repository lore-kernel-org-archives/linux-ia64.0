Received: from mout.web.de (mout.web.de [212.227.15.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D90E25290F;
	Thu,  3 Apr 2025 17:47:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743702448; cv=none; b=Sm8JwQJSRntlnZRAt6zqNFURgrNyQzyIjaCkt22xZQZfSPyR5xRYCJwK2BqwmhIsWqNdKRrBudhOPIe4LcV5a0sEBKJsJ1Oi2NoOQKGwEzSMq3NTSIKoGbzHnxJdCX3TdnVBYdgadEf6iX3nvhYtNhz+Pic3fZsk1FxEaOormjY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743702448; c=relaxed/simple;
	bh=KnIkky881MVh3vPKqjE4oYQv0uJJfiv3nzCYlzLw3T4=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:References:
	 In-Reply-To:Content-Type; b=ZDU610VJs8QPlF6KinB653cQADFXouyyIf06qc3SweNC33l6Hk18r3X2G2u/+jLTHD2CNrJEQf7xKEv9HTtboFhcMUF9slxYKXJS9SGXYdYpc9fWWUUNbw7ZnsuLoWL2I8uMCwI0Wr3RJhDlX8ykbKPo/kNBCz47Vf7IWusoeZ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=I1RUVEfj; arc=none smtp.client-ip=212.227.15.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="I1RUVEfj"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1743702418; x=1744307218; i=frank.scheiner@web.de;
	bh=H1sIW/fE2PWhkLk+OKhCS+zpamXiY+kKyuMISklWwjg=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:From:Subject:To:
	 Cc:References:In-Reply-To:Content-Type:Content-Transfer-Encoding:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=I1RUVEfj6M/lrSVs2nXUN+F3Za0oLDTfoIUwyR6Bu/LpFTSVVYPEWG2SfVFyq95c
	 787U9IXeSotxvVgAc4BABi6gFmZ8WEZpiiypd8fC46jeCY03yV5b0RFRHmWS412FT
	 k54lKBckaqGH5m1NxtS0ZnCai28WcWeJVwN9VQ8S1CCFJqXtOTyWTwix8SLEAQGka
	 GH8cmvRQF6HaRXhaIXCwlzH95HwJV8/qfJibrvHmeM3mNIxVdwhcLV/qneCnY7qaI
	 p540z3cH0BZ+7+H2ToDBlg38AL7lb/KOMR2DNDUJiwHQtO8A55jL+LMRIS47vZXOG
	 FS8Fh0iMQwQ+4468oQ==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([84.152.250.142]) by smtp.web.de (mrweb006
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MPKB7-1tk7Fn0k6n-00WvM9; Thu, 03
 Apr 2025 19:46:58 +0200
Message-ID: <703d6f83-f054-48ec-a6da-6d0bbb9e65d4@web.de>
Date: Thu, 3 Apr 2025 19:46:52 +0200
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Frank Scheiner <frank.scheiner@web.de>
Subject: Re: [PATCH v6 04/10] genirq: Introduce common
 irq_force_complete_move() implementation
To: Thomas Gleixner <tglx@linutronix.de>, apatel@ventanamicro.com
Cc: ajones@ventanamicro.com, andrew@lunn.ch, anup@brainfault.org,
 atishp@atishpatra.org, bp@alien8.de, dave.hansen@linux.intel.com,
 gregory.clement@bootlin.com, hpa@zytor.com, imx@lists.linux.dev,
 kernel@pengutronix.de, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-riscv@lists.infradead.org,
 maz@kernel.org, mingo@redhat.com, palmer@dabbelt.com,
 paul.walmsley@sifive.com, s.hauer@pengutronix.de,
 sebastian.hesselbarth@gmail.com, shawnguo@kernel.org,
 sunilvl@ventanamicro.com, x86@kernel.org, linux-ia64@vger.kernel.org
References: <20250217085657.789309-5-apatel@ventanamicro.com>
 <667d272f-2b51-49d6-84ea-1156027e00a7@web.de> <87plhtuw18.ffs@tglx>
Content-Language: en-US
In-Reply-To: <87plhtuw18.ffs@tglx>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:6MNV5zoHY7hCQ09bvOvJwv3kuECz3WxUa2bfbadzKiu8Nz/PUk3
 r4khTzLDonSLMS3CB0XogqYaE7OGkBBDVuYsfF7qkxe8x0p0ZXmBcDc+d+D3/cCMpa95o/j
 UunubNqjcMWGWkDIi36mSeYWey1wj5Vc325jNhAElfvL0lItLmH5oJW4HJ5twGTwB3HdGoR
 efZJC73+zd6VD6Ca/b8yQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:vihVRggBLIw=;40mu8nvRzyn28pHYR+tyRa+glGA
 L9dS9EZZnssU8CZpd3S0dRgfmlpEQMuKMP36srLrat7dg5KrFfS5QcrpJSNuOyhAv8VTFe4wi
 eM5ASGmb4b5QPFNc64n1mPnJRMMnXF3OoAzouVuuussBJmCsgg1so5ORWeak/+WHLezyKpJic
 jaATezrrWdJ0nig2NE3MOAwfQqd5v6gCARk8fafoldUX7MVaL9Q7SDYyFq8pdgHNG7hdU6z7J
 njGKJCpE2tFVXuvZb/En9b24JwPRRbOBvQdat55Ww2oZGd3JKtzA/AYdHHailozKEDkiPX3rt
 i8iNamTaevB0GZZFVK2HrRFWW96+lcMx4wcNNDK0f12+TDMKseXGzou55pLMupGdGoeXCc6/6
 JTOyTCOl+soVnuCNxVuQHfhLbIHXRyRMj0tsAq53kgWxEAr+hiKOl5gLeC2RbPl6JBgWeAXFH
 +ngvCfZWtwvqUmZLakj4oK7mRkJlcyy19zHS6Umr+McoUXVf0xm3AWpHTaVwvuoydLGiKXed8
 R5dRi61Tpuk4p6X4Pbslq+PkNiecpXPYHqZkxUFZn2rgiV/f63abYRkHPFrkFVM11XmP/1jJZ
 Dq11OJT/XaumPqPD+UoCq7AtjXnkmMYzPvwsNF2/LVNRGPRNK5HGz5hNCCpnc0nOcI5IiXzYR
 Ph0nGHt85yOBMhE1bdwtb9tLpTECZ9v6Jd5MArIhEd4hAuofPQ11mNN2iM5t9U56JMVP1+ATc
 TrAz8UmO1f1NH0GV20zn4+SYOWiu6YWGGvJFxjco7QworCrMR1mQlEaWMjRHWfcUSW6eRtPfM
 3MoF+2DBb+3E7G+hY7Oc7vzzEtckiRR3OzrYmOE1FokZgb71WdlLUDbdo1xHsnpKJZgKAyqfJ
 9fX78iSu0CNN/8We7scRn3oMFmpi1CsidTvnZMEeL91sKLGP0dnO3ilrb2UCDbVru0uCBjL1m
 nOA+AWsMUTXmrTrczxCNEoXyE93d7wqj2y1xprwW8AEaLcrmJxGwrpRo/5CnY9MLet6uYYJWw
 bUzI6SKOIrkZdJhURWeF/BJzhFokJLtc9N9XzoDf3HOc8klP1P335Ss/i+rxI52jA9VUZNFc3
 qHQuKxHyyiSpE4Y/QQumO0K4y4Y06LGxpmmeXnhOXvuGGYqq7mCGw+ruDiovKdLg/usdctrsI
 dWLoSkllh27rNJcFiCSIM0Yc9Rkge2gf5KphceWpSY2PWU0fGMp/awsUa7bu0Ffre5l6TfyUj
 DyZQavkfN3Mlj7dDrPIapKO5jtRpoRYCXTLl/L6qeloJk4C3zRQJf2fMKOqjO6BuYfbZO3vOn
 tCDlr4+pNXnGH59LWm3v32wIVYTpPn+zG6o0NGy5NW+qBTi0juCMJN3xnKTKuTe9ZjT9VW0Dd
 2FWe00Y0QziOltsETzc+OWc2wZ58YY0J0IUYZU/WcO2ZYprxjRmytNS282nz4TEdkGNtJ+VCp
 C7w/BVQ==

On 03.04.25 17:03, Thomas Gleixner wrote:
> On Thu, Apr 03 2025 at 15:13, Frank Scheiner wrote:
>> this change, specfically the introduction of irq_force_complete_move()
>> to `kernel/irq/migration.c`, strangely breaks our builds for the hp-sim
>> platform (i.e. Linux/ia64 for Ski):
>
> arch/itanic has hit the iceberg and sank with the release of v6.7...

Ha, ha, not in our waters. :-) Still I'm glad I could help finding
errors in Linux by building for ia64.


>> So I guess, either the requirement in `linux/include/linux/irq.h` needs
>> to go, or the use of "d->parent_data" or the whole of
>> irq_force_complete_move() and its use needs to be guarded as well.
>
> Guessing is not a really good approach to solve a technical problem :)

Thanks for the advice, though guessing was not involved here. It's just
a way to say that I'm not sure what the right solution might be in this
case. And then I'd rather leave such fixes to the experts in the
specific field.

> ---
> --- a/kernel/irq/migration.c
> +++ b/kernel/irq/migration.c
> @@ -37,7 +37,7 @@ bool irq_fixup_move_pending(struct irq_d
>
>  void irq_force_complete_move(struct irq_desc *desc)
>  {
> -	for (struct irq_data *d =3D irq_desc_get_irq_data(desc); d; d =3D d->p=
arent_data) {
> +	for (struct irq_data *d =3D irq_desc_get_irq_data(desc); d; d =3D irqd=
_get_parent_data(d)) {
>  		if (d->chip && d->chip->irq_force_complete_move) {
>  			d->chip->irq_force_complete_move(d);
>  			return;
>

This fxes the build for me for that file. Much obliged.
```
  CC      kernel/irq/migration.o
```

Cheers,
Frank
