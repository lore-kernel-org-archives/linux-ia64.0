From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 01 Mar 2001 19:29:28 +0000
Subject: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

Anyone who can explain why there is a 

define_int CONFIG_IA64_L1_CACHE_SHIFT 6

in the config file? We already have SMP_CACHE_BYTES and L1_CACHE bytes
for all architectures, it doesn't make a whole lot of sense to me ot
invent yet another alignment rule.

Jes


