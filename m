From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 30 Nov 2001 05:46:37 +0000
Subject: Re: [Linux-ia64] where to set rr for uncached region
Message-Id: <marc-linux-ia64-105590698805564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805542@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805542@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Nov 2001 16:34:21 +0900, nomura@hpc.bs1.fc.nec.co.jp said:

  >> Hi, Thank you for your suggestion. It's a better approach.
  >> Though putting the check in __call_console_drivers() does fix the
  >> problem, it's not satisfactory. Because, until cpu_online_map is
  >> set up, log_buf is flushed without printing.

  >> So I put the check in release_console_sem().  How about this fix?

Works for me.

Thanks,

	--david

