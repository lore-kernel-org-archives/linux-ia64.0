From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Jun 2004 01:10:29 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <16592.61317.129353.62981@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 15 Jun 2004 21:52:26 +0900, "Kaigai Kohei" <kaigai@ak.jp.nec.com> said:

  Kaigai> I'm sorry the patch attached with the previous mail was
  Kaigai> wrong.  Please ignore it. orz

  Kaigai> The patch attached with this mail is the latest version.

OK, I check this in now, with a small change to the ia64_switch_to()
portion, so that the instructions get packed better.

Thanks for tracking this down and fixing it!

	--david
