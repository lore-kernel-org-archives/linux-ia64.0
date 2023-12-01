Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="PulDj90a";
	dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="MM+my8yu"
Received: from galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 58250194;
	Fri,  1 Dec 2023 08:09:13 -0800 (PST)
From: Thomas Gleixner <tglx@linutronix.de>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020; t=1701446951;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uKxRp/dNJ+BlEYqlGWZid2nfWI8vIHVdIFhT+RiI/qw=;
	b=PulDj90aXiRlz0KIPhVWwqgHjbNY+GfW1XmvAqmiTU2UUTadptMLOgWxpw0sglnecWPxm2
	h3pQxvz/efyUkT0DzR6Zifyj/teIVv7LRNanyfOBCaopUgzyOdYP3BramvDqzLCaPgyMXH
	G2oUSl2ZtKWMTHxX9On5rvWRR93FCNkui+7QBPmn1fSY/iCGndY24luM31PjHukQxZY+ND
	QsyOE8crYC1sCWSj2foqen7+kQNVXcV4Jw3XBAzPRS3pU5nlDBmFRtVCbC4XYuwCPsNN5g
	EAnr8d8MCcDefPToBuDYeCdDAC+tenJqC5OG0gxx1dEo831rwsbpRsdF8dDGDw==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
	s=2020e; t=1701446951;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=uKxRp/dNJ+BlEYqlGWZid2nfWI8vIHVdIFhT+RiI/qw=;
	b=MM+my8yufzTM5emNEOVfJBfSeaclWykJ/U1d2msgD5/TqhIRuKqH2clFiM3a1nH+LeR7kF
	F5zFA8wjF+8cUiDg==
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Russell King (Oracle)" <linux@armlinux.org.uk>,
 linux-pm@vger.kernel.org, loongarch@lists.linux.dev,
 linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-riscv@lists.infradead.org, kvmarm@lists.linux.dev, x86@kernel.org,
 linux-csky@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Albert Ou
 <aou@eecs.berkeley.edu>, Borislav Petkov <bp@alien8.de>, Catalin Marinas
 <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Guo
 Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Huacai Chen
 <chenhuacai@kernel.org>, Ingo Molnar <mingo@redhat.com>, James Morse
 <james.morse@arm.com>, Jean-Philippe Brucker <jean-philippe@linaro.org>,
 jianyong.wu@arm.com, justin.he@arm.com, Len Brown <lenb@kernel.org>,
 Palmer Dabbelt <palmer@dabbelt.com>, Paul Walmsley
 <paul.walmsley@sifive.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael
 J. Wysocki" <rafael@kernel.org>, Salil Mehta <salil.mehta@huawei.com>,
 Sudeep Holla <sudeep.holla@arm.com>, WANG Xuerui <kernel@xen0n.name>, Will
 Deacon <will@kernel.org>
Subject: Re: [PATCH 00/21] Initial cleanups for vCPU hotplug
In-Reply-To: <2023120131-leotard-deprecate-4e27@gregkh>
References: <ZVyz/Ve5pPu8AWoA@shell.armlinux.org.uk> <87plzqxiyl.ffs@tglx>
 <2023120131-leotard-deprecate-4e27@gregkh>
Date: Fri, 01 Dec 2023 17:09:10 +0100
Message-ID: <87jzpxykex.ffs@tglx>
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On Fri, Dec 01 2023 at 12:28, Greg Kroah-Hartman wrote:
> I can take them, will do so this weekend when I catch up on patches on a
> 14+ hour flight...

Thanks a lot!

