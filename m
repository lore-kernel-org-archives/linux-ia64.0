From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 01 Mar 2001 22:35:14 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_L1_CACHE_SHIFT
Message-Id: <marc-linux-ia64-105590693005239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005236@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005236@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 01 Mar 2001 20:29:28 +0100, Jes Sorensen <jes@linuxcare.com> said:

  Jes> Hi Anyone who can explain why there is a

  Jes> define_int CONFIG_IA64_L1_CACHE_SHIFT 6

  Jes> in the config file? We already have SMP_CACHE_BYTES and
  Jes> L1_CACHE bytes for all architectures, it doesn't make a whole
  Jes> lot of sense to me ot invent yet another alignment rule.

$ fgrep CONFIG_IA64_L1 include/asm-ia64/cache.h 
#define L1_CACHE_SHIFT          CONFIG_IA64_L1_CACHE_SHIFT

	--david

