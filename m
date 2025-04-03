Received: from mout.web.de (mout.web.de [212.227.15.3])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC92124E004;
	Thu,  3 Apr 2025 13:13:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.3
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743686029; cv=none; b=eXXz+4LkoG1IVajozSG7EPnF8nBMKaS+vpWvajlpTu/a21LwSBM8Ddj72HeyCroGyiYKFX4l6bXIgICwcQQTuaVHJyhQgv6azuZKqUIy3+YkiIzayzRD98mKcKpRkqHlNVJU5sfwu15XGqX1ycZYq+5ENlHza6PTKJpSd4EtZqU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743686029; c=relaxed/simple;
	bh=oO2YyQYecVr+L4x0Yq8tpuXt1Blol50iC56ZhetCIAw=;
	h=Message-ID:Date:MIME-Version:To:Cc:References:Subject:From:
	 In-Reply-To:Content-Type; b=WW7w/EQnT+3WNJA3b4Sqvilg6+N78IOHtSgNcA3E+ID7q4K69Pq2SY7mf9Qj7pumma8Lawfx3dkWS8w8/BmtEK4kk476Q93n4H10P0kyfE2hpFSTu+oWuQKe6fcGO/BSRgxt+BH4sQNfxFd/G5LY5ahqtk053us4/urMLR2nqlA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de; spf=pass smtp.mailfrom=web.de; dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b=jfpaWPDn; arc=none smtp.client-ip=212.227.15.3
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=web.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=web.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=web.de header.i=frank.scheiner@web.de header.b="jfpaWPDn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=web.de;
	s=s29768273; t=1743686000; x=1744290800; i=frank.scheiner@web.de;
	bh=tq7Ewy84FWklJ0DM2lQqRrm1CFpORg7fNcv68fsFdoI=;
	h=X-UI-Sender-Class:Message-ID:Date:MIME-Version:To:Cc:References:
	 Subject:From:In-Reply-To:Content-Type:Content-Transfer-Encoding:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=jfpaWPDnqJlnn7d/eeKA+Q2dZ6gal+i27mW+REj0gdj86oe2hrp1rhPGmf7hy4Ps
	 ucG7L7EDOF3MG/YJSYMNsvXaoeAKKiuPIFKvghBUxWs4T0rF+acXD/NDt/siXGzgj
	 X8f+hJQZhTuPvqizGbwQAxuDK/ujk+GUPNZiM23PgGRC+xqSE/cfFEUrP53QV4RkI
	 /N9DJ3bgz0roFD3YAqpyx7Bhmo015EwlCP2gSdoAbC8cJABBh/AsC+r5dxNClp5Tq
	 L8ZyLbPeuNYG25J7trpGWIC1FtQp75NBD/OGH5SqZaeU8skoKP3ftavD+VnXM6vfa
	 S+xM5OLloka1ig34xA==
X-UI-Sender-Class: 814a7b36-bfc1-4dae-8640-3722d8ec6cd6
Received: from [192.168.178.30] ([84.152.250.142]) by smtp.web.de (mrweb005
 [213.165.67.108]) with ESMTPSA (Nemesis) id 1MZSBG-1tco0U2pmQ-00IJ9N; Thu, 03
 Apr 2025 15:13:20 +0200
Message-ID: <667d272f-2b51-49d6-84ea-1156027e00a7@web.de>
Date: Thu, 3 Apr 2025 15:13:17 +0200
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: apatel@ventanamicro.com
Cc: ajones@ventanamicro.com, andrew@lunn.ch, anup@brainfault.org,
 atishp@atishpatra.org, bp@alien8.de, dave.hansen@linux.intel.com,
 gregory.clement@bootlin.com, hpa@zytor.com, imx@lists.linux.dev,
 kernel@pengutronix.de, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-riscv@lists.infradead.org,
 maz@kernel.org, mingo@redhat.com, palmer@dabbelt.com,
 paul.walmsley@sifive.com, s.hauer@pengutronix.de,
 sebastian.hesselbarth@gmail.com, shawnguo@kernel.org,
 sunilvl@ventanamicro.com, tglx@linutronix.de, x86@kernel.org,
 linux-ia64@vger.kernel.org
References: <20250217085657.789309-5-apatel@ventanamicro.com>
Subject: Re: [PATCH v6 04/10] genirq: Introduce common
 irq_force_complete_move() implementation
Content-Language: en-US
From: Frank Scheiner <frank.scheiner@web.de>
In-Reply-To: <20250217085657.789309-5-apatel@ventanamicro.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Provags-ID: V03:K1:XEpgZJH4hjXKrAVtN6WYfb76caRsH3G/1YZh0k6iv/5gAuOD6JZ
 /5tde3RwkXrkd/Pey4Lz/oZqXIOJwitxEp+fORe/ccUTmOxTdKdt1JHSPo7f6gtuJfxNzDZ
 CT0pBBS+/1TDZFBQT8c7xRTvQ04Ld/hNbLksOh9snnDnKPRk4pMuFmuPo7JqqG7e0gsfnuM
 o7r8alGP5hXS3FrAzPIkg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:Of7XFgulvNQ=;OVh5LHzbZMeUCHWhdl2nXotRgit
 jM6j1jgD5opSeNE7yy/Joxn4dWxgFOVQNAKd/9JrMF5rl1I5wvE1WrzuIA55muGKCafDi+qNf
 VM/TKsQ5FYBPmRxIMIODE9vSzoN8nXhbs4547OCs/oQraFxSR2fQCUvX+/XD/H2fu07WZxDF5
 JiKyCXLZkwYuP49khkI1RPsWSuznFlZUD8xkeB8OkRIsOAAn1AmhQGeWaigIF8080IM0X8SJC
 /Q0MEC4U0PoYB6fVozKBItqDoDSyPT8v2xUPgpM4eqIEUz/mnXKAAbNZqlQhNx7VJQwkdljWy
 hanRggjC+qcyvNnLv4+wWV361WVPE0XqVtSWkPJVSerVB5ZvzYYDvKDy3rAZSunshNvPPkjjd
 nF2CDEmIkniaETkOsdfzv/bGnskgZxhNsUDmjt12xjJgtp7/OfqAJ4sV12Ni2o06jYqHCIntJ
 lAv1rJYy7HWdYf1eu5xtCgIz2GZossoQJvhoC6EMXI4aAS2+xuYfuaoQARne38XIb6Vp4yv7p
 LJ2UP9ONGwFBoW/2qaBKubFr/6edJ0npfgdLzR0HkovRPwe1Xw1xCOO6OOwvVoklqrUOZ2iQ3
 EJVg8HRlqql/7e0imy9xYuEaQpU6K7d9u4FYppWQILPTr0N8xW1vJ9P0YUf7Rf4znCKxsoS1F
 MKPB83tuLCXlQ5bG+q1Q9bxzHNyPNlhWh6AuWdY0+XbRKYXf1JTDJUlxSn3J464O2RPfPmqdH
 HDVSisM8e0I7C2Fzl9Gi2irOvjG78Pena6EpnNuhC2GbMVwM0HuEH9dVI8ZqtVQp9koggzIzA
 h126Bu/qYCnPX6wXzAfJAnf4X/8HbAQowX13W7CCxhdd4U+PioOYYWXHPkYx6nO5OiCCvJ6wC
 t4DcaQPA6IPUC2xmwpZ1iuyUMpNNT/3wbfPwE64sa6/CZXKN9f+9j4UnsQDKfw4okD1iQnwhd
 Me4LKEO/bYQrmX4ZB7PwRFV4KFK7498IYaO26+frpSRi3Qdo8SKDIS462jGpd0qsELf3rporN
 VSGoBRFYikvqgrNVjiF9ItOmcRROIjXooW4kWaQj0kEyKbuqUP/QBtx+e553himBLKWRbXQgL
 2mT4LxpzgUB8pez1+EeTuoBBpnKPHLs8Lb5+MyIBhjxgyhlQcXmCWF8K/4PyimOqbld6BVBkB
 b9c897IE7qU4qZr4claegKPHTOt4zT3q3ERrHiC9shhf1l2jKNJAghCAwuQFOgZ2fudl7W8dH
 KvEZ3v9n2hpNTq6auTCW9guBFFRV8x/yI6TBWhZCNwS1me+uL8jO2BFF7UsXh1k0o21Lr6g01
 9aVgDoQ7l/vgmrgyB4Q8U0n33dGHKGuujhqJuFENBBhBe/faxIMPYUI8/pmGoK9/KWTKz1rqf
 Mtr0mYNyydPx0M/YfvQCBhIITMLSUsU8z8F7zjYKtscMJFtszwQTLMRjqgV9A/k+5dxBAIvcW
 KOMwjXQ==

Hi there,

this change, specfically the introduction of irq_force_complete_move()
to `kernel/irq/migration.c`, strangely breaks our builds for the hp-sim
platform (i.e. Linux/ia64 for Ski):

```
  CC      kernel/irq/affinity.o
kernel/irq/migration.c: In function 'irq_force_complete_move':
kernel/irq/migration.c:40:72: error: 'struct irq_data' has no member named 'parent_data'
   40 |         for (struct irq_data *d = irq_desc_get_irq_data(desc); d; d = d->parent_data) {
      |                                                                        ^~
make[4]: *** [scripts/Makefile.build:207: kernel/irq/migration.o] Error 1
```

The reason seems to be that "d->parent_data" (i.e.
"irq_data.parent_data") is used unguarded in this function:

```
void irq_force_complete_move(struct irq_desc *desc)
{
    for (struct irq_data *d = irq_desc_get_irq_data(desc); d; d = d->parent_data) {
        if (d->chip && d->chip->irq_force_complete_move) {
            d->chip->irq_force_complete_move(d);
            return;
        }
    }
}
```

...but "parent_data" is only present in `include/linux/irq.h` if
`CONFIG_IRQ_DOMAIN_HIERARCHY` was selected.

```
struct irq_data {
    u32            mask;
    unsigned int        irq;
    irq_hw_number_t        hwirq;
    struct irq_common_data    *common;
    struct irq_chip        *chip;
    struct irq_domain    *domain;
#ifdef    CONFIG_IRQ_DOMAIN_HIERARCHY
    struct irq_data        *parent_data;
#endif
    void            *chip_data;
};
```

So I guess, either the requirement in `linux/include/linux/irq.h` needs
to go, or the use of "d->parent_data" or the whole of
irq_force_complete_move() and its use needs to be guarded as well.

Cheers,
Frank

