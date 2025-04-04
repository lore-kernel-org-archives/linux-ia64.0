Received: from galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 395D233CFC;
	Fri,  4 Apr 2025 14:51:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.142.43.55
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743778283; cv=none; b=KPc9yvlfJvlT+xfqibVNF4nnHb51xoG2GQb8k0kKNgeUqw3NP7Cpd+j/XuVBqWHb8lquZ9mhnB/9xekABR1VKEB2W6XTvkqEPA5fMznD9CIjD52HkvN758GrMQA6Y9NAwTg8UlK8udTB6H63tWcnQkJ/+BbwWHvNy4SmxPOh1IA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743778283; c=relaxed/simple;
	bh=4p/WOaI76+0YwPV5FSf9gdz0Q8KnFrz1PR6ICSw+g/0=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=r5W0S1ITBh+q7Z0+mKnfAQHqgw5g2RGJxqullkPMFZA3yYJRSVJQzTmRblRmnQ30FqXzfa2hGRfMxx9FqKvqxHH7y4rmf/Xs6/vAPFjx/0NE7pm7TFCWHTS+wbZod+SaXI9Cyp82eZq4RwGwGakgNXtbb5J0mSX2Ds6d+1mDd80=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linutronix.de; spf=pass smtp.mailfrom=linutronix.de; dkim=pass (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b=oCFQjRbd; dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b=rIh6e55K; arc=none smtp.client-ip=193.142.43.55
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linutronix.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linutronix.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="oCFQjRbd";
	dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="rIh6e55K"
From: Thomas Gleixner <tglx@linutronix.de>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020; t=1743778280;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ki7u9cfXUyQNld/a1MIArILl2CpoC7PHwvBk36BVlsk=;
	b=oCFQjRbdDC64UiVAB8XTsODZJtPQRW8QwstyLQ24xtMSqdK3xQzaVS9MmjUhAHeOGgnSIf
	MENe7aGCyGdj+uU95oB/OEC9nazAb0a7u04t2GpgBek84RUEOhTphFwH8+PaIpr38HM2SA
	5K6o26RNsVz5fK20Dk5xHAb+3AOhrLmbgK85qWloI2Ly36oaFbNiblAxtWZSdIKkrvMjRa
	O0WY6XY0k8RmoQCTDCTr3zrGgg2joq5p0Qhq/D+yRxKr1thkv6tpZFq0E1eadcKrnRoJNE
	CW5Ne7NTG7VePTkaTGB+6qf/W738lGRE8Dmit4cQ4dNkuy3JYNN5tjpt6RwcVA==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020e; t=1743778280;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ki7u9cfXUyQNld/a1MIArILl2CpoC7PHwvBk36BVlsk=;
	b=rIh6e55KM2pp2K0N0UFeNgcRmAHMNzgV6U/rG+M1JXj/scAulduj5+Qof6daIkGohPC2SP
	n+pWkJBuf5yu19Bg==
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
Subject: [PATCH] genirq/migration: Use irqd_get_parent_data() in
 irq_force_complete_move()
In-Reply-To: <703d6f83-f054-48ec-a6da-6d0bbb9e65d4@web.de>
References: <20250217085657.789309-5-apatel@ventanamicro.com>
 <667d272f-2b51-49d6-84ea-1156027e00a7@web.de> <87plhtuw18.ffs@tglx>
 <703d6f83-f054-48ec-a6da-6d0bbb9e65d4@web.de>
Date: Fri, 04 Apr 2025 16:51:19 +0200
Message-ID: <87h634ugig.ffs@tglx>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

Frank reported, that the common irq_force_complete_move() breaks the out of
tree build of ia64. The reason is that ia64 uses the migration code, but
does not have hierarchical interrupt domains enabled.

This went unnoticed in mainline as both x86 and RISC-V have hierarchical
domains enabled. Not that it matters for mainline, but it's still
inconsistent.

Use irqd_get_parent_data() instead of accessing the parent_data field
directly. The helper returns NULL when hierarchical domains are disabled
otherwise it accesses the parent_data field of the domain.

No functional change.

Fixes: 751dc837dabd ("genirq: Introduce common irq_force_complete_move() implementation")
Reported-by: Frank Scheiner <frank.scheiner@web.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Frank Scheiner <frank.scheiner@web.de>

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




