From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 11 Nov 2002 19:22:59 +0000
Subject: [Linux-ia64] (no subject)
Message-Id: <marc-linux-ia64-105590709805386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205296@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205296@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 11 Nov 2002 10:29:29 -0600, Mario Smarduch <cms063@email.mot.com> said:

  Mario> I know that on some commercial Unix systems there are ways to
  Mario> cap the CPU utilization by user/group ids are there such
  Mario> features/patches available on Linux?

There are probably other patches floating around, but Process Resource
Management (PRM) for Linux is/was one approach to do just that:

	http://resourcemanagement.unixsolutions.hp.com/WaRM/prm_linux/

The kernel patches available from this URL are pretty old (up to
2.4.6, as far as I could see), and I'm not sure what the future plans
for PRM on Linux are.  Perhaps someone else can provide more details.

	--david

