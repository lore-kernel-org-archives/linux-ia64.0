From: Andreas Schwab <schwab@suse.de>
Date: Mon, 18 Aug 2003 15:46:17 +0000
Subject: 2.6.0-test3: #undef SMP && #define NUMA does not compile
Message-Id: <marc-linux-ia64-106122187228169@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

When configuring 2.6.0-test3 with CONFIG_SMP disabled and CONFIG_NUMA
enabled I get undefined references to cpu_to_node_map and
node_to_cpu_mask.  Both variables are defined in
arch/ia64/kernel/smpboot.c, thus only available for SMP.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
