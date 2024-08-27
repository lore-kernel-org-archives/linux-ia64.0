Received: from mail.tradeharmony.pl (mail.tradeharmony.pl [5.196.29.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA3B215B54C
	for <linux-ia64@vger.kernel.org>; Tue, 27 Aug 2024 07:58:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=5.196.29.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724745522; cv=none; b=XKO0EQlTgvPPfWf5vYH9FezTqPORLPZ+nHZVVXuGK7joFH8os/p/9CFZ/eKKfsC3gyZfRpPMnUioTg3CpjkFu3KT4hsuNaUZr+A/M7LStfnwptcyPGqQ3DneEqOe0Z0SBw03yJt+++wsiATBQLOTveTeK5o3v0Yq7Bm9n4BTNck=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724745522; c=relaxed/simple;
	bh=siHX5jVClg4W32F/NjlCmIL8w17yqZEkZP0Dfrdd7Ok=;
	h=Message-ID:Date:From:To:Subject:MIME-Version:Content-Type; b=MiA4vXfxzdL21eGn7HJYIfw58nrNbEq2S5magBrTYPdua1LcvMUk2k1BnxibHnlzp+PV8ztJ0dLqjZLA+ZCvTf9d91VVpOriPM9u9nQ4GbRgbEb60xc57pIASA1GCbAXmO/0fM9wqjR/JmCwXPYTHsFDLqDx/lxEfTaQcspJTSk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tradeharmony.pl; spf=pass smtp.mailfrom=tradeharmony.pl; dkim=pass (2048-bit key) header.d=tradeharmony.pl header.i=@tradeharmony.pl header.b=PpTx0DB2; arc=none smtp.client-ip=5.196.29.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tradeharmony.pl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=tradeharmony.pl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=tradeharmony.pl header.i=@tradeharmony.pl header.b="PpTx0DB2"
Received: by mail.tradeharmony.pl (Postfix, from userid 1002)
	id D615C275BC; Tue, 27 Aug 2024 09:56:15 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tradeharmony.pl;
	s=mail; t=1724745432;
	bh=siHX5jVClg4W32F/NjlCmIL8w17yqZEkZP0Dfrdd7Ok=;
	h=Date:From:To:Subject:From;
	b=PpTx0DB2Bl+FuM8GMMe7crYwIs4YrKSpwOjnU71n1dCxYKqM5cECRTGXZNEjON86t
	 cClG2yR3Z7eroqLDhvbtIXNvHgRMv1W4JGIGufBNAxJSBAdC5255qDxHSt52Z8hKbH
	 FjBdzW7ZTYBqmwV0IZEq1oq8dUDrQ0z/cxuqLH9H0yXRYwe0ohh7QMs7v45d2OVTv5
	 6+xLGkiOzh8rAQ45TDida5f8Ve6uDM1b/+oBdlqqiyB2O/81cfUtftO9WzFarDUJ4u
	 +UHYMEwSWzOCtMsiYLuRdq8Yc8gV6Th0x7oD3gsn4ipY2DOolh1slkMmDH79pDkt9g
	 t1Cnrt1gby5FQ==
Received: by mail.tradeharmony.pl for <linux-ia64@vger.kernel.org>; Tue, 27 Aug 2024 07:55:59 GMT
Message-ID: <20240827084500-0.1.8a.2xj5g.0.c7y7k2zkdr@tradeharmony.pl>
Date: Tue, 27 Aug 2024 07:55:59 GMT
From: "Karol Michun" <karol.michun@tradeharmony.pl>
To: <linux-ia64@vger.kernel.org>
Subject: =?UTF-8?Q?Pytanie_o_samoch=C3=B3d_?=
X-Mailer: mail.tradeharmony.pl
Precedence: bulk
X-Mailing-List: linux-ia64@vger.kernel.org
List-Id: <linux-ia64.vger.kernel.org>
List-Subscribe: <mailto:linux-ia64+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-ia64+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dzie=C5=84 dobry,

Czy interesuje Pa=C5=84stwa rozwi=C4=85zanie umo=C5=BCliwiaj=C4=85ce moni=
torowanie samochod=C3=B3w firmowych oraz optymalizacj=C4=99 koszt=C3=B3w =
ich utrzymania?=20


Pozdrawiam
Karol Michun
