From: Andreas Schwab <schwab@suse.de>
Date: Wed, 10 Mar 2004 22:54:12 +0000
Subject: Re: show_mem panic
Message-Id: <jer7w0cnzf.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040310180923.GA9032@sgi.com>
In-Reply-To: <20040310180923.GA9032@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

> It's in the inner loop looking at the pages in the first node's
> node_mem_map.  I'm almost positive that this code worked in the past,
> Andreas, when you reproduced this on a tiger machine was it with
> CONFIG_VIRTUAL_MEM_MAP enabled?

Yes, that's our standard configuration.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
