From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 13 Feb 2004 00:51:58 +0000
Subject: Re: [patch] 2.6.3-rc2 Delete redundant ia64_mca_check_errors
Message-Id: <16428.8110.190031.658893@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2568.1076632427@kao2.melbourne.sgi.com>
In-Reply-To: <2568.1076632427@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 13 Feb 2004 11:33:47 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> salinfo automatically processes all record types on all cpus
  Keith> at boot time, ia64_mca_check_errors is now redundant.  This
  Keith> also removes the need for a called_from_init flag on
  Keith> ia64_mca_log_sal_error_record.

OK, this one was better... ;-)

	--david
