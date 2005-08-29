From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 29 Aug 2005 02:41:04 +0000
Subject: ip_contrack module refuses to load...
Message-Id: <17170.30144.755169.205802@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


With linux 2.6.13-rc7, compiled with either gcc 4.0 or 3.4 I see:


ip_tables: (C) 2000-2002 Netfilter core team
ip_conntrack: value -6917529019048071580 out of IMM22 range

in dmesg.

That value doesn't correspond to any symbol I can find in
/proc/kallsyms (it's A0000002002EEE64: symbols near there are:

a0000002002b6ed0 s now  [autofs4]
a0000002002c7000 ? __mod_description35  [ip_tables]
a0000002002c7020 ? __mod_author34       [ip_tables]
a0000002002c7058 ? __mod_license33      [ip_tables]
a0000002002c7068 ? __module_depends     [ip_tables]
a0000002002c7078 ? __mod_vermagic5      [ip_tables]
ffffffffffff0028 U per_cpu__cpu_info    [e1000]
ffffffffffff0028 U per_cpu__cpu_info    [snd_ac97_codec]
ffffffffffff0028 U per_cpu__cpu_info    [snd_fm801]
ffffffffffff0028 U per_cpu__cpu_info    [snd_mpu401_uart]
)

Any ideas?
