From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 26 Jun 2001 17:30:37 +0000
Subject: [Linux-ia64] Re: volatile unsigned long cpu_online_map vs unsigned long cpu_online_map
Message-Id: <marc-linux-ia64-105590693005778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005772@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005772@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Jun 2001 12:24:20 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> Also, shoudn't it be extern in at least one of
  Bill> setup.c/smpboot.c?

I already have taken care of that in the latest source tree.  I don't
think it causes any problems.

	--david

