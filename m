Received: from galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB4FA24F5A0;
	Thu,  3 Apr 2025 15:03:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.142.43.55
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743692631; cv=none; b=H+7x9mz/CdRAQAbNIYOGeLXYkgeX706CAPRUz/ZdaY++53CwzGb2ROKBYoqicx0Ub6axq3qajwliDajlD/u5GOQwd4PcSB+LSnqe0mKWxYmb4nYt1+CWoXd1NhVC793X27C+aN5IGi3GQAz3eb5gP7yXkgU7wSar3o7/CggrbBE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743692631; c=relaxed/simple;
	bh=KcyDK4uz+Y/Sokp66zbb4AM3+lCIWhqWPIEAVHmRr54=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=dz23GuVuR9PV9NXk5VbufRNbf4ORx0+cKd2eT6JNV6o47IfzxcIlSmUYb6V6ekNjOtafn8ggTk17QKh4Xf7+qQDUqDtC8gPFsIyBQvWxVD9DxlylDW7T6RH4qXfGAjNhiZLOUwrVR0Npy68L5tQON/gewfLvHT6FuwwYiIDbUFk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linutronix.de; spf=pass smtp.mailfrom=linutronix.de; dkim=pass (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b=cAWc2c6X; dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b=aMNLw6Bi; arc=none smtp.client-ip=193.142.43.55
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linutronix.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linutronix.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="cAWc2c6X";
	dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="aMNLw6Bi"
From: Thomas Gleixner <tglx@linutronix.de>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020; t=1743692627;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=EHbCePX24dh6KDJ8X+RFQ5xBFtUQ6++YcFww5RU2/aM=;
	b=cAWc2c6X5BJpIpgjOXnZKqynoDf4CCrEuzivOkx71QQg/6/melJAeT2Y0DX7p/hlhj9uPf
	7bUp6mjwtjQlKwFOlixaVLeAx9I7JRykqitt+QPbBUWL9I3StpxaotwDB9q30gHnf7i9NA
	LDhy/Pk3MgTqW6UUar4Eky5xJDAbbYJmE2ijdsz4KBB/jkHPNjncBzn7JE16phj7GPD6+l
	WrLvwzbPTBqlF2vplEep3bug91J5/tFuP9szoX1LDmvvJpEK9epMer5BBawdO8X1yOPr54
	WKujMmMS2NAHXP52D2ZQgKt+ppsKgPL9R9PHxynKL2RTQaFBujamNzGVP/Bifw==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020e; t=1743692627;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=EHbCePX24dh6KDJ8X+RFQ5xBFtUQ6++YcFww5RU2/aM=;
	b=aMNLw6BiyQBB/EaqECgC7EhDDvNwWSgmoZfQeRO5JsW6QuiIu5LwonVANOgI6USyH5VMS8
	d0alF73jquU26hDA==
To: Frank Scheiner <frank.scheiner@web.de>, apatel@ventanamicro.com
Cc: ajones@ventanamicro.com, andrew@lunn.ch, anup@brainfault.org,
 atishp@atishpatra.org, bp@alien8.de, dave.hansen@linux.intel.com,
 gregory.clement@bootlin.com, hpa@zytor.com, imx@lists.linux.dev,
 kernel@pengutronix.de, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-riscv@lists.infradead.org,
 maz@kernel.org, mingo@redhat.com, palmer@dabbelt.com,
 paul.walmsley@sifive.com, s.hauer@pengutronix.de,
 sebastian.hesselbarth@gmail.com, shawnguo@kernel.org,
 sunilvl@ventanamicro.com, x86@kernel.org, linux-ia64@vger.kernel.org
Subject: Re: [PATCH v6 04/10] genirq: Introduce common
 irq_force_complete_move() implementation
In-Reply-To: <667d272f-2b51-49d6-84ea-1156027e00a7@web.de>
References: <20250217085657.789309-5-apatel@ventanamicro.com>
 <667d272f-2b51-49d6-84ea-1156027e00a7@web.de>
Date: Thu, 03 Apr 2025 17:03:47 +0200
Message-ID: <87plhtuw18.ffs@tglx>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On Thu, Apr 03 2025 at 15:13, Frank Scheiner wrote:
> this change, specfically the introduction of irq_force_complete_move()
> to `kernel/irq/migration.c`, strangely breaks our builds for the hp-sim
> platform (i.e. Linux/ia64 for Ski):

arch/itanic has hit the iceberg and sank with the release of v6.7...

> So I guess, either the requirement in `linux/include/linux/irq.h` needs
> to go, or the use of "d->parent_data" or the whole of
> irq_force_complete_move() and its use needs to be guarded as well.

Guessing is not a really good approach to solve a technical problem :)

Thanks,

        tglx
---
--- a/kernel/irq/migration.c
+++ b/kernel/irq/migration.c
@@ -37,7 +37,7 @@ bool irq_fixup_move_pending(struct irq_d
 
 void irq_force_complete_move(struct irq_desc *desc)
 {
-	for (struct irq_data *d = irq_desc_get_irq_data(desc); d; d = d->parent_data) {
+	for (struct irq_data *d = irq_desc_get_irq_data(desc); d; d = irqd_get_parent_data(d)) {
 		if (d->chip && d->chip->irq_force_complete_move) {
 			d->chip->irq_force_complete_move(d);
 			return;




