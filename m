From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Apr 2001 21:48:57 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.3)
Message-Id: <marc-linux-ia64-105590693005459@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 24 Apr 2001 23:05:17 +0200, Jes Sorensen <jes@linuxcare.com> said:

  Jes> Basically the issue is that once you go to glibc-2.2.3 you need
  Jes> the latest kernel as well and vice versa.

glibc-2.2.3 should work fine with older kernels (well, not _too_ old,
but the AT_ENTRY fix should work both with old and new kernels).

	--david

